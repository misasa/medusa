desc "bib authors csv"
task :bib_authors_csv => :environment do
  ActiveRecord::Base.establish_connection :medusa_original
  
  ActiveRecord::Base.connection.execute("
    COPY(
      SELECT *
      FROM bibliographies
    )
    TO '/tmp/csv/bibliographies.csv'
    (FORMAT 'csv', HEADER);
  ")
  
  CSV.open("/tmp/csv/author_tests.csv", "w")
  
  authors_test = CSV.table("/tmp/csv/author_tests.csv")
  bibliographies = CSV.table("/tmp/csv/bibliographies.csv")
  
  bib_auth_array_all = bibliographies.map do |bib|
    bib[:authorlist].split(/, (?![A-Z]\.)/)
  end
  
  bib_auth_array_flat = bib_auth_array_all.flatten
  bib_auth_array_uniq_1 = bib_auth_array_flat.uniq
  
  bib_auth_array_uniq_2 = bib_auth_array_uniq_1.each do |authorlist|
    authorlist.gsub!(/and /, '')
  end
  
  bib_auth_array_uniq_3 = bib_auth_array_uniq_2.uniq
  
  today = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")
  
  bib_array = bib_auth_array_uniq_3.map.with_index(1) do |auth, i|
    [i, auth, today, today]
  end
  
  bib_array.each do |bib|
    authors_test << bib
  end
  
  authors_csv = authors_test.to_csv(write_headers: false)
  
  File.open("/tmp/csv/authors.csv", "w") do |csv_file|
    csv_file.print("id,name,created_at,updated_at\n")
    csv_file.print(authors_csv)
  end
  
  authors = CSV.table("/tmp/csv/authors.csv")
  
  authors_hash = authors.each_with_object({}) do |author, hash|
    hash[author[:name]] = author[:id]
  end
  
  bibliographies_hash = bibliographies.each_with_object({}) do |biblio, hash|
    hash[biblio[:id]] = biblio[:authorlist]
  end
  
  new_bibliographies_hash_1 = bibliographies_hash.each do |bib_id, author_names|
    bibliographies_hash[bib_id] = author_names.split(/, (?![A-Z]\.)/)
  end
  
  new_bibliographies_hash_2 = new_bibliographies_hash_1.each do |bib_id, author_names|
    author_names.each do |author_name|
      author_name.gsub!(/and /, '')
    end
  end
  
  bib_authors = []
  new_bibliographies_hash_2.each do |bib_id, author_names|
    author_names.each do |name|
      bib_authors << [bib_id, authors_hash[name]]
    end
  end
  
  bib_authors_array = bib_authors.map.with_index(1) do |bib_auth, i|
    [i, bib_auth].flatten
  end
  
  bib_authors_csv = []
  bib_authors_array.each do |bib_author|
    bib_authors_csv << bib_author.to_csv(write_headers: false)
  end
  
  File.open("/tmp/csv/bib_authors.csv", "w") do |csv_file|
    csv_file.print("id,bib_id,author_id\n")
    bib_authors_csv.map {|bib_author_csv| csv_file.print(bib_author_csv)}
  end
  
  ActiveRecord::Base.establish_connection :development
  
  ActiveRecord::Base.connection.execute("
    COPY bib_authors
    FROM '/tmp/csv/bib_authors.csv'
    WITH CSV HEADER
  ")
  
  max_next_bib_author_id = ActiveRecord::Base.connection.select_value("
    SELECT MAX(id)
    FROM bib_authors
  ").to_i
  
  ActiveRecord::Base.connection.execute("
    SELECT setval('bib_authors_id_seq', #{max_next_bib_author_id})
  ")
  
  FileUtils.rm("/tmp/csv/bibliographies.csv")
  FileUtils.rm("/tmp/csv/author_tests.csv")
  FileUtils.rm("/tmp/csv/authors.csv")
  
end