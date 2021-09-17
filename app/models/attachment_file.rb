require 'matrix'
require 'RubyFits'
class AttachmentFile < ApplicationRecord
  include HasRecordProperty
  has_attached_file :data,
    styles: { 
      :large => ["100%", :png],
      :medium => ["250x250>", :png],
      :thumb => ["160x120>", :png], 
      :tiny => ["50x50", :png]
    },
    path: ":rails_root/public/system/:class/:id_partition/:basename_with_style.:extension",
    url: "#{Rails.application.config.relative_url_root}/system/:class/:id_partition/:basename_with_style.:extension",
    restricted_characters: /[&$+,x\/:;=?<>\[\]\{\}\|\\\^~%# ]/

  validates_attachment_content_type :data, 
  :content_type => [
    "application/msword",
    "application/octet-stream",
    "application/pdf",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/x-photoshop",
    "application/x-zip-compressed",
    "application/zip",
    "image/bmp",
    "image/gif",
    "image/jpeg",
    "image/jpg",
    "image/pjpeg",
    "image/png",
    "image/svg+xml",
    "image/tiff",
    "text/plain",
    "image/fits" ]

  alias_attribute :name, :data_file_name

  has_many :spots, dependent: :destroy, inverse_of: :attachment_file
  has_many :attachings, dependent: :destroy
  has_many :specimens, -> { order(:name) }, through: :attachings, source: :attachable, source_type: "Specimen"
  has_many :places, through: :attachings, source: :attachable, source_type: "Place"
  has_many :boxes, -> { order(:name) }, through: :attachings, source: :attachable, source_type: "Box"
  has_many :bibs, through: :attachings, source: :attachable, source_type: "Bib"
  has_many :analyses, through: :attachings, source: :attachable, source_type: "Analysis"
  has_many :surface_images, foreign_key: :image_id
  has_many :surfaces, :through => :surface_images, dependent: :destroy
  has_one :analysis, foreign_key: :fits_file_id
  attr_accessor :path
  before_post_process :skip_for_fits
  after_post_process :save_geometry

#  after_save :rotate
  after_save :check_affine_matrix
  after_save :update_spots_world_xy
  after_save :fits2png

  after_create :generate_analysis
  after_update :rename_attached_files_if_needed

  serialize :affine_matrix, Array

  validates :data, presence: true

  scope :fits_files, -> { where(data_content_type: ["application/octet-stream", "image/fits"]).where('(attachment_files.data_file_name like ?)', '%.fits') }

  @colormap = {
    rainbow: [0,0,0,255,50,21,67,255,51,24,74,255,52,27,81,255,53,30,88,255,54,33,95,255,55,36,102,255,56,39,109,255,57,42,115,255,58,45,121,255,59,47,128,255,60,50,134,255,61,53,139,255,62,56,145,255,63,59,151,255,63,62,156,255,64,64,162,255,65,67,167,255,65,70,172,255,66,73,177,255,66,75,181,255,67,78,186,255,68,81,191,255,68,84,195,255,68,86,199,255,69,89,203,255,69,92,207,255,69,94,211,255,70,97,214,255,70,100,218,255,70,102,221,255,70,105,224,255,70,107,227,255,71,110,230,255,71,113,233,255,71,115,235,255,71,118,238,255,71,120,240,255,71,123,242,255,70,125,244,255,70,128,246,255,70,130,248,255,70,133,250,255,70,135,251,255,69,138,252,255,69,140,253,255,68,143,254,255,67,145,254,255,66,148,255,255,65,150,255,255,64,153,255,255,62,155,254,255,61,158,254,255,59,160,253,255,58,163,252,255,56,165,251,255,55,168,250,255,53,171,248,255,51,173,247,255,49,175,245,255,47,178,244,255,46,180,242,255,44,183,240,255,42,185,238,255,40,188,235,255,39,190,233,255,37,192,231,255,35,195,228,255,34,197,226,255,32,199,223,255,31,201,221,255,30,203,218,255,28,205,216,255,27,208,213,255,26,210,210,255,26,212,208,255,25,213,205,255,24,215,202,255,24,217,200,255,24,219,197,255,24,221,194,255,24,222,192,255,24,224,189,255,25,226,187,255,25,227,185,255,26,228,182,255,28,230,180,255,29,231,178,255,31,233,175,255,32,234,172,255,34,235,170,255,37,236,167,255,39,238,164,255,42,239,161,255,44,240,158,255,47,241,155,255,50,242,152,255,53,243,148,255,56,244,145,255,60,245,142,255,63,246,138,255,67,247,135,255,70,248,132,255,74,248,128,255,78,249,125,255,82,250,122,255,85,250,118,255,89,251,115,255,93,252,111,255,97,252,108,255,101,253,105,255,105,253,102,255,109,254,98,255,113,254,95,255,117,254,92,255,121,254,89,255,125,255,86,255,128,255,83,255,132,255,81,255,136,255,78,255,139,255,75,255,143,255,73,255,146,255,71,255,150,254,68,255,153,254,66,255,156,254,64,255,159,253,63,255,161,253,61,255,164,252,60,255,167,252,58,255,169,251,57,255,172,251,56,255,175,250,55,255,177,249,54,255,180,248,54,255,183,247,53,255,185,246,53,255,188,245,52,255,190,244,52,255,193,243,52,255,195,241,52,255,198,240,52,255,200,239,52,255,203,237,52,255,205,236,52,255,208,234,52,255,210,233,53,255,212,231,53,255,215,229,53,255,217,228,54,255,219,226,54,255,221,224,55,255,223,223,55,255,225,221,55,255,227,219,56,255,229,217,56,255,231,215,57,255,233,213,57,255,235,211,57,255,236,209,58,255,238,207,58,255,239,205,58,255,241,203,58,255,242,201,58,255,244,199,58,255,245,197,58,255,246,195,58,255,247,193,58,255,248,190,57,255,249,188,57,255,250,186,57,255,251,184,56,255,251,182,55,255,252,179,54,255,252,177,54,255,253,174,53,255,253,172,52,255,254,169,51,255,254,167,50,255,254,164,49,255,254,161,48,255,254,158,47,255,254,155,45,255,254,153,44,255,254,150,43,255,254,147,42,255,254,144,41,255,253,141,39,255,253,138,38,255,252,135,37,255,252,132,35,255,251,129,34,255,251,126,33,255,250,123,31,255,249,120,30,255,249,117,29,255,248,114,28,255,247,111,26,255,246,108,25,255,245,105,24,255,244,102,23,255,243,99,21,255,242,96,20,255,241,93,19,255,240,91,18,255,239,88,17,255,237,85,16,255,236,83,15,255,235,80,14,255,234,78,13,255,232,75,12,255,231,73,12,255,229,71,11,255,228,69,10,255,226,67,10,255,225,65,9,255,223,63,8,255,221,61,8,255,220,59,7,255,218,57,7,255,216,55,6,255,214,53,6,255,212,51,5,255,210,49,5,255,208,47,5,255,206,45,4,255,204,43,4,255,202,42,4,255,200,40,3,255,197,38,3,255,195,37,3,255,193,35,2,255,190,33,2,255,188,32,2,255,185,30,2,255,183,29,2,255,180,27,1,255,178,26,1,255,175,24,1,255,172,23,1,255,169,22,1,255,167,20,1,255,164,19,1,255,161,18,1,255,158,16,1,255,155,15,1,255,152,14,1,255,149,13,1,255,146,11,1,255,142,10,1,255,139,9,2,255,136,8,2,255,133,7,2,255,129,6,2,255,126,5,2,255,255,255,255,255],
    viridis: [0,0,0,255,68,2,86,255,69,4,87,255,69,5,89,255,70,7,90,255,70,8,92,255,70,10,93,255,70,11,94,255,71,13,96,255,71,14,97,255,71,16,99,255,71,17,100,255,71,19,101,255,72,20,103,255,72,22,104,255,72,23,105,255,72,24,106,255,72,26,108,255,72,27,109,255,72,28,110,255,72,29,111,255,72,31,112,255,72,32,113,255,72,33,115,255,72,35,116,255,72,36,117,255,72,37,118,255,72,38,119,255,72,40,120,255,72,41,121,255,71,42,122,255,71,44,122,255,71,45,123,255,71,46,124,255,71,47,125,255,70,48,126,255,70,50,126,255,70,51,127,255,70,52,128,255,69,53,129,255,69,55,129,255,69,56,130,255,68,57,131,255,68,58,131,255,68,59,132,255,67,61,132,255,67,62,133,255,66,63,133,255,66,64,134,255,66,65,134,255,65,66,135,255,65,68,135,255,64,69,136,255,64,70,136,255,63,71,136,255,63,72,137,255,62,73,137,255,62,74,137,255,62,76,138,255,61,77,138,255,61,78,138,255,60,79,138,255,60,80,139,255,59,81,139,255,59,82,139,255,58,83,139,255,58,84,140,255,57,85,140,255,57,86,140,255,56,88,140,255,56,89,140,255,55,90,140,255,55,91,141,255,54,92,141,255,54,93,141,255,53,94,141,255,53,95,141,255,52,96,141,255,52,97,141,255,51,98,141,255,51,99,141,255,50,100,142,255,50,101,142,255,49,102,142,255,49,103,142,255,49,104,142,255,48,105,142,255,48,106,142,255,47,107,142,255,47,108,142,255,46,109,142,255,46,110,142,255,46,111,142,255,45,112,142,255,45,113,142,255,44,113,142,255,44,114,142,255,44,115,142,255,43,116,142,255,43,117,142,255,42,118,142,255,42,119,142,255,42,120,142,255,41,121,142,255,41,122,142,255,41,123,142,255,40,124,142,255,40,125,142,255,39,126,142,255,39,127,142,255,39,128,142,255,38,129,142,255,38,130,142,255,38,130,142,255,37,131,142,255,37,132,142,255,37,133,142,255,36,134,142,255,36,135,142,255,35,136,142,255,35,137,142,255,35,138,141,255,34,139,141,255,34,140,141,255,34,141,141,255,33,142,141,255,33,143,141,255,33,144,141,255,33,145,140,255,32,146,140,255,32,146,140,255,32,147,140,255,31,148,140,255,31,149,139,255,31,150,139,255,31,151,139,255,31,152,139,255,31,153,138,255,31,154,138,255,30,155,138,255,30,156,137,255,30,157,137,255,31,158,137,255,31,159,136,255,31,160,136,255,31,161,136,255,31,161,135,255,31,162,135,255,32,163,134,255,32,164,134,255,33,165,133,255,33,166,133,255,34,167,133,255,34,168,132,255,35,169,131,255,36,170,131,255,37,171,130,255,37,172,130,255,38,173,129,255,39,173,129,255,40,174,128,255,41,175,127,255,42,176,127,255,44,177,126,255,45,178,125,255,46,179,124,255,47,180,124,255,49,181,123,255,50,182,122,255,52,182,121,255,53,183,121,255,55,184,120,255,56,185,119,255,58,186,118,255,59,187,117,255,61,188,116,255,63,188,115,255,64,189,114,255,66,190,113,255,68,191,112,255,70,192,111,255,72,193,110,255,74,193,109,255,76,194,108,255,78,195,107,255,80,196,106,255,82,197,105,255,84,197,104,255,86,198,103,255,88,199,101,255,90,200,100,255,92,200,99,255,94,201,98,255,96,202,96,255,99,203,95,255,101,203,94,255,103,204,92,255,105,205,91,255,108,205,90,255,110,206,88,255,112,207,87,255,115,208,86,255,117,208,84,255,119,209,83,255,122,209,81,255,124,210,80,255,127,211,78,255,129,211,77,255,132,212,75,255,134,213,73,255,137,213,72,255,139,214,70,255,142,214,69,255,144,215,67,255,147,215,65,255,149,216,64,255,152,216,62,255,155,217,60,255,157,217,59,255,160,218,57,255,162,218,55,255,165,219,54,255,168,219,52,255,170,220,50,255,173,220,48,255,176,221,47,255,178,221,45,255,181,222,43,255,184,222,41,255,186,222,40,255,189,223,38,255,192,223,37,255,194,223,35,255,197,224,33,255,200,224,32,255,202,225,31,255,205,225,29,255,208,225,28,255,210,226,27,255,213,226,26,255,216,226,25,255,218,227,25,255,221,227,24,255,223,227,24,255,226,228,24,255,229,228,25,255,231,228,25,255,234,229,26,255,236,229,27,255,239,229,28,255,241,229,29,255,244,230,30,255,246,230,32,255,248,230,33,255,251,231,35,255,255,255,255,255],
    greys: [0, 0, 0, 255, 1, 1, 1, 255, 2, 2, 2, 255, 3, 3, 3, 255, 4, 4, 4, 255, 5, 5, 5, 255, 6, 6, 6, 255, 7, 7, 7, 255, 8, 8, 8, 255, 9, 9, 9, 255, 10, 10, 10, 255, 11, 11, 11, 255, 12, 12, 12, 255, 13, 13, 13, 255, 14, 14, 14, 255, 15, 15, 15, 255, 16, 16, 16, 255, 17, 17, 17, 255, 18, 18, 18, 255, 19, 19, 19, 255, 20, 20, 20, 255, 21, 21, 21, 255, 22, 22, 22, 255, 23, 23, 23, 255, 24, 24, 24, 255, 25, 25, 25, 255, 26, 26, 26, 255, 27, 27, 27, 255, 28, 28, 28, 255, 29, 29, 29, 255, 30, 30, 30, 255, 31, 31, 31, 255, 32, 32, 32, 255, 33, 33, 33, 255, 34, 34, 34, 255, 35, 35, 35, 255, 36, 36, 36, 255, 37, 37, 37, 255, 38, 38, 38, 255, 39, 39, 39, 255, 40, 40, 40, 255, 41, 41, 41, 255, 42, 42, 42, 255, 43, 43, 43, 255, 44, 44, 44, 255, 45, 45, 45, 255, 46, 46, 46, 255, 47, 47, 47, 255, 48, 48, 48, 255, 49, 49, 49, 255, 50, 50, 50, 255, 51, 51, 51, 255, 52, 52, 52, 255, 53, 53, 53, 255, 54, 54, 54, 255, 55, 55, 55, 255, 56, 56, 56, 255, 57, 57, 57, 255, 58, 58, 58, 255, 59, 59, 59, 255, 60, 60, 60, 255, 61, 61, 61, 255, 62, 62, 62, 255, 63, 63, 63, 255, 64, 64, 64, 255, 65, 65, 65, 255, 66, 66, 66, 255, 67, 67, 67, 255, 68, 68, 68, 255, 69, 69, 69, 255, 70, 70, 70, 255, 71, 71, 71, 255, 72, 72, 72, 255, 73, 73, 73, 255, 74, 74, 74, 255, 75, 75, 75, 255, 76, 76, 76, 255, 77, 77, 77, 255, 78, 78, 78, 255, 79, 79, 79, 255, 80, 80, 80, 255, 81, 81, 81, 255, 82, 82, 82, 255, 83, 83, 83, 255, 84, 84, 84, 255, 85, 85, 85, 255, 86, 86, 86, 255, 87, 87, 87, 255, 88, 88, 88, 255, 89, 89, 89, 255, 90, 90, 90, 255, 91, 91, 91, 255, 92, 92, 92, 255, 93, 93, 93, 255, 94, 94, 94, 255, 95, 95, 95, 255, 96, 96, 96, 255, 97, 97, 97, 255, 98, 98, 98, 255, 99, 99, 99, 255, 100, 100, 100, 255, 101, 101, 101, 255, 102, 102, 102, 255, 103, 103, 103, 255, 104, 104, 104, 255, 105, 105, 105, 255, 106, 106, 106, 255, 107, 107, 107, 255, 108, 108, 108, 255, 109, 109, 109, 255, 110, 110, 110, 255, 111, 111, 111, 255, 112, 112, 112, 255, 113, 113, 113, 255, 114, 114, 114, 255, 115, 115, 115, 255, 116, 116, 116, 255, 117, 117, 117, 255, 118, 118, 118, 255, 119, 119, 119, 255, 120, 120, 120, 255, 121, 121, 121, 255, 122, 122, 122, 255, 123, 123, 123, 255, 124, 124, 124, 255, 125, 125, 125, 255, 126, 126, 126, 255, 127, 127, 127, 255, 128, 128, 128, 255, 129, 129, 129, 255, 130, 130, 130, 255, 131, 131, 131, 255, 132, 132, 132, 255, 133, 133, 133, 255, 134, 134, 134, 255, 135, 135, 135, 255, 136, 136, 136, 255, 137, 137, 137, 255, 138, 138, 138, 255, 139, 139, 139, 255, 140, 140, 140, 255, 141, 141, 141, 255, 142, 142, 142, 255, 143, 143, 143, 255, 144, 144, 144, 255, 145, 145, 145, 255, 146, 146, 146, 255, 147, 147, 147, 255, 148, 148, 148, 255, 149, 149, 149, 255, 150, 150, 150, 255, 151, 151, 151, 255, 152, 152, 152, 255, 153, 153, 153, 255, 154, 154, 154, 255, 155, 155, 155, 255, 156, 156, 156, 255, 157, 157, 157, 255, 158, 158, 158, 255, 159, 159, 159, 255, 160, 160, 160, 255, 161, 161, 161, 255, 162, 162, 162, 255, 163, 163, 163, 255, 164, 164, 164, 255, 165, 165, 165, 255, 166, 166, 166, 255, 167, 167, 167, 255, 168, 168, 168, 255, 169, 169, 169, 255, 170, 170, 170, 255, 171, 171, 171, 255, 172, 172, 172, 255, 173, 173, 173, 255, 174, 174, 174, 255, 175, 175, 175, 255, 176, 176, 176, 255, 177, 177, 177, 255, 178, 178, 178, 255, 179, 179, 179, 255, 180, 180, 180, 255, 181, 181, 181, 255, 182, 182, 182, 255, 183, 183, 183, 255, 184, 184, 184, 255, 185, 185, 185, 255, 186, 186, 186, 255, 187, 187, 187, 255, 188, 188, 188, 255, 189, 189, 189, 255, 190, 190, 190, 255, 191, 191, 191, 255, 192, 192, 192, 255, 193, 193, 193, 255, 194, 194, 194, 255, 195, 195, 195, 255, 196, 196, 196, 255, 197, 197, 197, 255, 198, 198, 198, 255, 199, 199, 199, 255, 200, 200, 200, 255, 201, 201, 201, 255, 202, 202, 202, 255, 203, 203, 203, 255, 204, 204, 204, 255, 205, 205, 205, 255, 206, 206, 206, 255, 207, 207, 207, 255, 208, 208, 208, 255, 209, 209, 209, 255, 210, 210, 210, 255, 211, 211, 211, 255, 212, 212, 212, 255, 213, 213, 213, 255, 214, 214, 214, 255, 215, 215, 215, 255, 216, 216, 216, 255, 217, 217, 217, 255, 218, 218, 218, 255, 219, 219, 219, 255, 220, 220, 220, 255, 221, 221, 221, 255, 222, 222, 222, 255, 223, 223, 223, 255, 224, 224, 224, 255, 225, 225, 225, 255, 226, 226, 226, 255, 227, 227, 227, 255, 228, 228, 228, 255, 229, 229, 229, 255, 230, 230, 230, 255, 231, 231, 231, 255, 232, 232, 232, 255, 233, 233, 233, 255, 234, 234, 234, 255, 235, 235, 235, 255, 236, 236, 236, 255, 237, 237, 237, 255, 238, 238, 238, 255, 239, 239, 239, 255, 240, 240, 240, 255, 241, 241, 241, 255, 242, 242, 242, 255, 243, 243, 243, 255, 244, 244, 244, 255, 245, 245, 245, 255, 246, 246, 246, 255, 247, 247, 247, 255, 248, 248, 248, 255, 249, 249, 249, 255, 250, 250, 250, 255, 251, 251, 251, 255, 252, 252, 252, 255, 253, 253, 253, 255, 254, 254, 254, 255, 255, 255, 255, 255]
  }
  def path(style = :original)
    if File.exists?(data.path(style))
      return data.url(style)
    else
      base_name = File.basename(data.path(style),".*")
      ext_name = File.extname(data.path(style))
      original_ext_name = File.extname(data.path(:original))
      _path = data.path(style).sub(/#{ext_name}/,original_ext_name)
      if File.exists?(_path)
        return data.url(style).sub(/#{ext_name}/,original_ext_name)
      else
        return data.url(:original)
      end
    end
  end

  def as_json(options = {})
    super({:methods => [:affine_matrix_in_string, :bounds, :corners_on_world, :width_in_um, :height_in_um, :original_path, :thumbnail_path, :tiny_path, :global_id]}.merge(options))
  end

  def surface_spots
    Spot.with_surfaces(self.surfaces)
  end

  def surface_spots_within_image
    surface_spots.within_image(self)
  end

  def surface_spots_within_bounds
    surface_spots.within_bounds(self.bounds)
  end

  def surface_spots_within_image_converted
    ospots = []
    #ospots = surface_spots_within_image
    #spot_xys = self.world_pairs_on_pixel(ospots.pluck(:world_x, :world_y))
    surface_spots_within_image.each_with_index do |spot, index|
      if spot.attachment_file_id == self.id
        ospots << spot
      else
        spot.attachment_file_id = self.id
        if spot.world_x && spot.world_y
          spot_xys = self.world_pairs_on_pixel([[spot.world_x, spot.world_y]])
          spot.spot_x = spot_xys[0][0]
          spot.spot_y = spot_xys[0][1]
          spot.radius_in_percent = spot.radius_percent_from_um
          ospots << spot
        end
      end
    end
    ospots
  end

  def surface_spots_within_bounds_converted
    ospots = surface_spots_within_bounds
    spot_xys = self.world_pairs_on_pixel(ospots.pluck(:world_x, :world_y))
    ospots.each_with_index do |spot, index|
      spot.attachment_file_id = self.id if spot.attachment_file_id != self.id
      spot.spot_x = spot_xys[index][0]
      spot.spot_y = spot_xys[index][1]
      spot.radius_in_percent = spot.radius_percent_from_um
    end
    ospots
  end

  def original_path
    path
  end


  def thumbnail_path
    path(:thumb)
  end

  def tiny_path
    path(:tiny)
  end

  def data_fingerprint
    self.md5hash
  end

  def data_fingerprint=(md5Hash)
    self.md5hash=md5Hash
  end

  def save_geometry
    self.original_geometry = Paperclip::Geometry.from_file(data.queued_for_write[:original]).to_s rescue nil
  end

  def local_path(style = :original)
    _path = data.path(style)
    if style == :warped
      _path = warped_path
    elsif (style == :png && fits_file?)
      _path = png_path
    end
    _path.sub(/\?\d+$/,"")
  end

  def warped_path
    _path = data.path
    dirname = File.dirname(_path)
    basename = File.basename(_path, ".*")
    File.join([dirname, basename + "_warped.png"])
    #File.join([Rails.root.to_s, "public", dirname, basename + "_warped.png"])
  end

  def png_path
    _path = data.path
    dirname = File.dirname(_path)
    basename = File.basename(_path, ".*")
    File.join([dirname, basename + ".png"])
  end

  def warped_url
    _url = data.url
    dirname = File.dirname(_url)
    basename = File.basename(_url, ".*")
    File.join([dirname, basename + "_warped.png"])
    #File.join([Rails.root.to_s, "public", dirname, basename + "_warped.png"])
  end

  def png_url(args = nil)
    _url = data.url(args)
    dirname = File.dirname(_url)
    basename = File.basename(_url, ".*")
    File.join([dirname, basename + ".png"])
    #File.join([Rails.root.to_s, "public", dirname, basename + "_warped.png"])
  end

  def check_affine_matrix
    if saved_change_to_affine_matrix?
      b, a = saved_change_to_affine_matrix
      if a.instance_of?(Array) && a.size == 9
        #RotateWorker.perform_async(id) unless a == [1,0,0,0,1,0,0,0,1]
        if surface_images.present?
          left,upper,right,bottom = bounds
          surface_images.each do |surface_image|
            surface_image.update(left: left, upper: upper, right: right, bottom: bottom)
            TileWorker.perform_async(surface_image.id)
          end
        end
      end
    end
  end

  def rotate
    logger.info("in rotate")

    raise "bounds does not exist." unless bounds
    if self.fits_file?
      local_path = self.png_path
    else
      local_path = self.local_path
    end
    raise "#{local_path} does not exist." unless File.exists?(local_path)
    raise "#{local_path} is not a image."unless (image? || fits_file?)
    logger.info("generating...")
    left, upper, right, bottom = bounds
    logger.info(bounds)
    bb = bounds
    b_w = right - left
    b_h = upper - bottom
    p_um = pixels_per_um
    new_geometry = [(b_w * p_um).ceil, (b_h * p_um).ceil]
    logger.info("new_geometry: #{new_geometry}")
    puts("new_geometry: #{new_geometry}")

    corners_on_new_image = []
    corners_on_world.each do |corner|
      dx = corner[0] - left
      dy = upper - corner[1]
      pixs = [(dx/b_w*new_geometry[0]).to_int, (dy/b_h*new_geometry[1]).to_int]
      corners_on_new_image << pixs
    end
    image_1 = local_path
    #image_2 = local_path(:warped)
    #temp_image = Tempfile.new(['warped-','.png'], "#{Rails.root.to_s}/tmp/")
    temp_image = Tempfile.new(['warped-','.png'])
    image_2 = temp_image.path
    temp_image.close!
    png = ChunkyPNG::Image.new(new_geometry[0], new_geometry[1])
    png.save(image_2)
    array_str = corners_on_new_image.to_s.gsub(/\s+/,"")

    line = Terrapin::CommandLine.new("image_in_image", "#{image_1} #{image_2} #{array_str} -p nearest -o #{image_2}", logger: logger)
    puts(line.command)
    line.run
    return image_2
  end


  def update_spots_world_xy
    #return unless affine_matrix_changed?
    spots.each do |spot|
      spot.world_x, spot.world_y = spot.spot_world_xy
      spot.radius_in_um = spot.radius_um_from_percent
      spot.save
    end
  end

  def rename_attached_files_if_needed
    return if !name_changed? || data_updated_at_changed?
    logger.info("renameing...")
    (data.styles.keys+[:original]).each do |style|
      path = data.path(style)
      dirname = File.dirname(path)
      extname = File.extname(path)
      basename = File.basename(data_file_name,'.*')
      old_basename = File.basename(data_file_name_was, '.*')
      old_path = File.join(dirname, File.basename(path).sub(basename, old_basename))
      logger.info("rename_attached_files: #{old_path} ->  #{path}")
      FileUtils.mv(old_path, path)
    end
  end

  def pdf?
    !(data_content_type =~ /pdf$/).nil?
  end

  def image?
    !(data_content_type =~ /^image.*/).nil?
  end

  def original_width
    return unless original_geometry
    original_geometry.split("x")[0].to_i
  end

  def original_height
    return unless original_geometry
    original_geometry.split("x")[1].to_i
  end

 def width(style = :original)
    if style == :original && original_geometry
      return original_width
    else
      width_from_file(style)
    end
  end

 def height(style = :original)
    if style == :original && original_geometry
      return original_height
    else
      height_from_file(style)
    end
  end

  def length
    #return unless self.image?
    if width && height
      return width >= height ? width : height
    else
      return nil
    end
  end

  def pixels_on_image(x, y)
    return if affine_matrix.blank?
    image_xy2image_coord(pixel2percent(x), pixel2percent(y))
  end

  def pixels_per_um
    um = width_in_um
    return unless um
    width/um
  end

  def pixels_on_world(x, y)
    im = pixels_on_image(x, y)
    affine_transform(*im)
  end

  def percent2pixel(percent)
    return unless self.image?
    return unless self.length && self.length > 0
    return self.length.to_f * percent / 100
  end

  def pixel2percent(pix)
    return unless self.image? || self.fits_file?
    return unless self.length && self.length > 0
    return pix/self.length.to_f * 100
  end

  def width_on_stage
    return if affine_matrix.blank?
    transform_length(width / length.to_f * 100)
  end

  def transform_length(l, type = :xy2world)
    src_points = [[0,0],[l,0]]
    dst_points = transform_points(src_points, type)
    return Math::sqrt((dst_points[0][0] - dst_points[1][0]) ** 2 + (dst_points[0][1] - dst_points[1][1]) ** 2)
  end

 def affine_matrix_in_string
    a = affine_matrix
    return unless a
    return if a.blank?
    str = ""
    a.in_groups_of(3, false) do |row|
      vals = Array.new
      row.each do |val|
        vals.push sprintf("%.5e",val) if val
      end
      str += vals.join(',')
      str += ';'
    end
    "[#{str.sub(/\;$/,'')}]"
  end

  def affine_matrix_in_string=(str)
    str = str.gsub(/\[/,"").gsub(/\]/,"").gsub(/\;/,",").gsub(/\s+/,"")
    tokens = str.split(',')
    vals = tokens.map{|token| token.to_f}
    vals.concat([0,0,1]) if vals.size == 6
    if vals.size == 9
      self.affine_matrix = vals
    end
  end

  def affine_transform(xs, ys)
    a = affine_matrix
    return unless a
    return if a.blank?
    #xyi = Array.new
    #xi = a[0] * xs + a[1] * ys + a[2]
    #yi = a[3] * xs + a[4] * ys + a[5]
    #return [xi, yi]
    return transform_points([[xs,ys]])[0]
  end

  def corners_on_image
    #return if affine_matrix.blank?
    [image_xy2image_coord(0,0), image_xy2image_coord(x_max,0), image_xy2image_coord(x_max,y_max), image_xy2image_coord(0,y_max)]
  end

  def corners_on_world=(_corners)
    corners_on_world_str = "[" + _corners.map{|_corner| _corner.join(',')}.join('],[') + "]"
    corners_on_image_str = "[" + self.corners_on_image.map{|_corner| _corner.join(',')}.join('],[') + "]"
    line = Terrapin::CommandLine.new("H_from_points", "#{corners_on_image_str} #{corners_on_world_str} -f yaml", logger: logger)
    line.run
    _out = line.output.output.chomp
    a = YAML.load(_out)
    self.affine_matrix = a.flatten
  end

  def corners_on_world
    return if affine_matrix.blank?
    a, b, c, d = corners_on_image
    [affine_transform(*a),affine_transform(*b),affine_transform(*c),affine_transform(*d)]
  end

  def bounds
    return Array.new(4) { nil } if affine_matrix.blank?
    cs = corners_on_world
    xi, yi = cs[0]
    left = xi
    right = xi
    upper = yi
    bottom = yi
    corners_on_world.each do |corner|
      x, y = corner
      left = x if x < left
      right = x if x > right
      bottom = y if y < bottom
      upper = y if y > upper
    end
    [left,upper,right,bottom]
  end

  def width_in_um
    return if affine_matrix.blank?
    ps = image_xy2image_coord(0,0)
    pe = image_xy2image_coord(x_max,0)
    p1 = affine_transform(*ps)
    p2 = affine_transform(*pe)
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    return Math.sqrt(dx * dx + dy * dy)
  end

  def height_in_um
    return if affine_matrix.blank?

    ps = image_xy2image_coord(0,0)
    pe = image_xy2image_coord(0,y_max)
    p1 = affine_transform(*ps)
    p2 = affine_transform(*pe)
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    return Math.sqrt(dx * dx + dy * dy)
  end

  def length_in_um
    w = width_in_um
    h = height_in_um
    if w && h
      w > h ? w : h
    else
    end
  end

  def to_svg(opts = {})
    x = opts[:x] || 0
    y = opts[:y] || 0
    width = opts[:width] || original_width
    height = opts[:height] || original_height


    image = %Q|<image xlink:href="#{path(:large)}" x="0" y="0" width="#{original_width}" height="#{original_height}" data-id="#{id}"/>|
    if surfaces.empty?
      spots.inject(image) { |svg, spot| svg + spot.to_svg }
    else
      surface_spots_within_image_converted.inject(image) { |svg, spot| svg + spot.to_svg }
    end
  end

  def pixel_pairs_on_world(pairs)
    xys = pairs.map{|pa| pixels_on_image(*pa)}
    transform_points(xys)
  end

  def world_pairs_on_pixel(pairs)
    return if affine_matrix.blank? || pairs.blank?
    xys = transform_points(pairs, :world2xy)
    xys.map{|x, y| image_coord2xy(x, y).map{|z| percent2pixel(z)} }
  end

  def calibration_points_on_pixel
    [
      [0, 0],
      [original_width, 0],
      [original_width, original_height]
    ]
  end

  def calibration_points_on_world
    return if affine_matrix.blank?
    pixel_pairs_on_world(calibration_points_on_pixel)
  end

  def fits_file?
    ['application/octet-stream', 'image/fits'].include?(data_content_type) && File.extname(data_file_name) == '.fits'
  end

  def default_display_range()
    return unless fits_file?
    h = fits_info
    mean = h[:mean]
    sigma = h[:sigma]
    r_min = (mean > 2.0 * sigma ? mean - 2.0 * sigma : 0.0)
    r_max = mean + 2.0 * sigma
    [r_min, r_max]
  end

  def fits_info
    return unless fits_file?
    data = NArray.to_na(fits_data)
    val = data[data.lt Float::INFINITY]
    mean = val.mean()
    sigma = val.stddev()
    return {mean: mean, sigma:sigma}
  end

  def fits_data
    return unless fits_file?
    fits = Fits::FitsFile.new()
    fits.open(data.path)
    pHDU=fits.hdu(0)
    pHDU.extend Fits
    pHDU.getAsArray()
  end

  def self.colormap(h, key = nil)
    h = 0 if h.nil? || h.nan?
    index = (h*255.0).to_i * 4
    if key && @colormap.has_key?(key.to_sym)
      rgbas = @colormap[key.to_sym]
    else
      rgbas = @colormap[:rainbow]
    end
    r,g,b,a = rgbas[index...(index + 4)]
    ChunkyPNG::Color.rgba(r,g,b,a)
  end

  def self.colormap_hsl(h)
    h = 1 if h.nan?
    rgb = ColorCode::HSL.new(h: 240*(1.0 - h), s:100, l:50).to_rgb.to_hash
    ChunkyPNG::Color.rgba(rgb[:r],rgb[:g],rgb[:b],255)
  end

  def fits2png(params = {})
    return unless fits_file?
    logger.info("fits2png #{png_path}...")
    #path = File.join(File.dirname(local_path), File.basename(local_path,".fits")) + ".png"
    png = fits_image(params)
    png.save(png_path)
  end

  def fits_image(params = {})
    return unless fits_file?
    data = NArray.to_na(fits_data)
    val = data[data.lt Float::INFINITY]
    mean = val.mean()
    sigma = val.stddev()
    r_min = params[:r_min] || (mean > 2.0 * sigma ? mean - 2.0 * sigma : 0.0)
    r_max = params[:r_max] || mean + 2.0 * sigma
    dim0, dim1 = data.shape()
    data[data.eq Float::INFINITY] = 0.0
    dd = data - r_min
    dd[dd.lt 0.0] = 0.0
    dd[dd.gt (r_max - r_min)] = (r_max - r_min)
    dd = dd/(r_max - r_min)
    #dd = data
    #dd[dd.gt 1.0] = 1.0
    #dd = (1.0 - dd) *240
    png = ChunkyPNG::Image.new(*data.shape(),ChunkyPNG::Color::TRANSPARENT)
    dd.to_a.each_with_index do |a, i|
      a.each_with_index do |h, j|
        #puts "(#{i},#{j}) #{h}"
        rgba = self.class.colormap(h, params[:color_map])
        png[i,j] = rgba
        #h = 1 if h.nan?
        #rgb = ColorCode::HSL.new(h: 240*(1.0 - h), s:100, l:50).to_rgb.to_hash
        #png[i,j] = ChunkyPNG::Color.rgba(rgb[:r],rgb[:g],rgb[:b],255)
      end
    end
    png
  end

  private
  def skip_for_fits
    flag = !(File.extname(data_file_name) == '.fits')
    flag
  end

  def generate_analysis
    if fits_file?
      self.build_analysis unless self.analysis
      self.analysis.name = File.basename(data_file_name,".*")
      self.analysis.save
    end
  end

  def x_max
      width.to_f/length.to_f * 100 if width
  end

  def y_max
      height.to_f/length.to_f * 100 if height
  end

  def image_xy2image_coord(x,y)
    center_point = [x_max/2, y_max/2]
    [x - center_point[0], center_point[1] - y]
  end

  def image_coord2xy(ix,iy)
    center_point = [x_max/2, y_max/2]
    [ix + center_point[0], center_point[1] - iy]
  end


  def array_to_matrix(array)
    m = Matrix[array[0..2],array[3..5],array[6..8]]
    return m
  end

  def affine_xy2world
    array_to_matrix(affine_matrix)
  end

  def affine_world2xy
    affine_xy2world.inv
  end

  def transform_points(points, type = :xy2world)
    case type
    when :world2xy
      affine = affine_world2xy
    else
      affine = affine_xy2world
    end

    num_points = points.size
    src_points = Matrix[points.map{|p| p[0]}, points.map{|p| p[1]}, Array.new(points.size, 1.0)]
    warped_points = (affine * src_points).to_a
    xt = warped_points[0]
    yt = warped_points[1]
    wt = warped_points[2]
    dst_points = []
    num_points.times do |i|
      dst_points << [xt[i]/wt[i], yt[i]/wt[i]]
    end
    return dst_points
  end

end
