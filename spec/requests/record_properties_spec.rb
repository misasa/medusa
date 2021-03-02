require 'spec_helper'

describe "record_property" do
  before do
    login login_user
    User.current = login_user
  end
  let(:login_user) { FactoryBot.create(:user) }
  let(:headers) { { "ACCEPT" => "application/json", "HTTP_ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "analyses" do
    let!(:analysis) { FactoryBot.create(:analysis) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      analysis.record_property.disposed = disposed
      analysis.record_property.lost = lost
      analysis.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/analyses/#{analysis.id}/record_property/dispose.json" }.to\
          change{ analysis.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/analyses/#{analysis.id}/record_property/dispose.json" }.to\
          change{ analysis.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/analyses/#{analysis.id}/record_property/restore.json" }.to\
          change{ analysis.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/analyses/#{analysis.id}/record_property/restore.json" }.to\
          change{ analysis.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/analyses/#{analysis.id}/record_property/lose.json" }.to\
          change{ analysis.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/analyses/#{analysis.id}/record_property/lose.json" }.to\
          change{ analysis.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/analyses/#{analysis.id}/record_property/found.json" }.to\
          change{ analysis.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/analyses/#{analysis.id}/record_property/found.json" }.to\
          change{ analysis.record_property.reload.lost }.from(true).to(false)
      end
    end
  end

  describe "attachment_files" do
    let!(:attachment_file) { FactoryBot.create(:attachment_file) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      attachment_file.record_property.disposed = disposed
      attachment_file.record_property.lost = lost
      attachment_file.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/attachment_files/#{attachment_file.id}/record_property/dispose.json" }.to\
          change{ attachment_file.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/attachment_files/#{attachment_file.id}/record_property/dispose.json" }.to\
          change{ attachment_file.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/attachment_files/#{attachment_file.id}/record_property/restore.json" }.to\
          change{ attachment_file.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/attachment_files/#{attachment_file.id}/record_property/restore.json" }.to\
          change{ attachment_file.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/attachment_files/#{attachment_file.id}/record_property/lose.json" }.to\
          change{ attachment_file.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/attachment_files/#{attachment_file.id}/record_property/lose.json" }.to\
          change{ attachment_file.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/attachment_files/#{attachment_file.id}/record_property/found.json" }.to\
          change{ attachment_file.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/attachment_files/#{attachment_file.id}/record_property/found.json" }.to\
          change{ attachment_file.record_property.reload.lost }.from(true).to(false)
      end
    end
  end

  describe "bibs" do
    let!(:bib) { FactoryBot.create(:bib) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      bib.record_property.disposed = disposed
      bib.record_property.lost = lost
      bib.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/bibs/#{bib.id}/record_property/dispose.json" }.to\
          change{ bib.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/bibs/#{bib.id}/record_property/dispose.json" }.to\
          change{ bib.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/bibs/#{bib.id}/record_property/restore.json" }.to\
          change{ bib.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/bibs/#{bib.id}/record_property/restore.json" }.to\
          change{ bib.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/bibs/#{bib.id}/record_property/lose.json" }.to\
          change{ bib.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/bibs/#{bib.id}/record_property/lose.json" }.to\
          change{ bib.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/bibs/#{bib.id}/record_property/found.json" }.to\
          change{ bib.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/bibs/#{bib.id}/record_property/found.json" }.to\
          change{ bib.record_property.reload.lost }.from(true).to(false)
      end
    end
  end

  describe "boxes" do
    let!(:box) { FactoryBot.create(:box) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      box.record_property.disposed = disposed
      box.record_property.lost = lost
      box.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/boxes/#{box.id}/record_property/dispose.json" }.to\
          change{ box.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/boxes/#{box.id}/record_property/dispose.json" }.to\
          change{ box.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/boxes/#{box.id}/record_property/restore.json" }.to\
          change{ box.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/boxes/#{box.id}/record_property/restore.json" }.to\
          change{ box.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/boxes/#{box.id}/record_property/lose.json" }.to\
          change{ box.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/boxes/#{box.id}/record_property/lose.json" }.to\
          change{ box.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/boxes/#{box.id}/record_property/found.json" }.to\
          change{ box.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/boxes/#{box.id}/record_property/found.json" }.to\
          change{ box.record_property.reload.lost }.from(true).to(false)
      end
    end
  end

  describe "places" do
    let!(:place) { FactoryBot.create(:place) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      place.record_property.disposed = disposed
      place.record_property.lost = lost
      place.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/places/#{place.id}/record_property/dispose.json" }.to\
          change{ place.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/places/#{place.id}/record_property/dispose.json" }.to\
          change{ place.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/places/#{place.id}/record_property/restore.json" }.to\
          change{ place.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/places/#{place.id}/record_property/restore.json" }.to\
          change{ place.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/places/#{place.id}/record_property/lose.json" }.to\
          change{ place.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/places/#{place.id}/record_property/lose.json" }.to\
          change{ place.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/places/#{place.id}/record_property/found.json" }.to\
          change{ place.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/places/#{place.id}/record_property/found.json" }.to\
          change{ place.record_property.reload.lost }.from(true).to(false)
      end
    end
  end

  describe "specimens" do
    let!(:specimen) { FactoryBot.create(:specimen) }
    let(:disposed) { false }
    let(:lost) { false }
    before do
      specimen.record_property.disposed = disposed
      specimen.record_property.lost = lost
      specimen.record_property.save!
    end
    context "dispose" do
      it "put dispose" do
        expect { put "/specimens/#{specimen.id}/record_property/dispose.json" }.to\
          change{ specimen.record_property.reload.disposed }.from(false).to(true)
      end
      it "patch dispose" do
        expect { patch "/specimens/#{specimen.id}/record_property/dispose.json" }.to\
          change{ specimen.record_property.reload.disposed }.from(false).to(true)
      end
    end
    context "restore" do
      let(:disposed) { true }
      it "put restore" do
        expect { put "/specimens/#{specimen.id}/record_property/restore.json" }.to\
          change{ specimen.record_property.reload.disposed }.from(true).to(false)
      end
      it "patch restore" do
        expect { patch "/specimens/#{specimen.id}/record_property/restore.json" }.to\
          change{ specimen.record_property.reload.disposed }.from(true).to(false)
      end
    end
    context "lose" do
      it "put lose" do
        expect { put "/specimens/#{specimen.id}/record_property/lose.json" }.to\
          change{ specimen.record_property.reload.lost }.from(false).to(true)
      end
      it "patch lose" do
        expect { patch "/specimens/#{specimen.id}/record_property/lose.json" }.to\
          change{ specimen.record_property.reload.lost }.from(false).to(true)
      end
    end
    context "found" do
      let(:lost) { true }
      it "put found" do
        expect { put "/specimens/#{specimen.id}/record_property/found.json" }.to\
          change{ specimen.record_property.reload.lost }.from(true).to(false)
      end
      it "patch found" do
        expect { patch "/specimens/#{specimen.id}/record_property/found.json" }.to\
          change{ specimen.record_property.reload.lost }.from(true).to(false)
      end
    end
  end
end
