# coding: utf-8

class BbsThread < ActiveRecord::Base
  attr_accessible :comment, :content_type, :delflag, :delkey, :email, :image, :imgdelflag, :name, :thumbnail, :title, :image_file
  
  validate :input_check, :on => :create
  before_create :input_form
  
  def input_check
    # 画像が添付された場合、
    if self.image.present?

      begin
        image_check = Magick::Image.from_blob(self.image).shift
        
#        unless %w(JPEG GIF PNG BMP).member?(image_check.format)
#          self.errors.add(:image, "format should be JPEG, GIF, PNG or BMP.")
#        end
      rescue Magick::ImageMagickError, RuntimeError => ex
        self.errors.add(:image, "should be an image file.")
      end
    else
      if self.comment.blank?
        self.errors.add(:comment, "is not input.")
      end
    end
  end
  
  # 画像データを取り出す
  # Content-Typeはバイナリから判定できないため保存する
  def image_file= (p)
    
    if p
      self.image = p.read
      self.content_type = p.content_type
    end
  end

  def input_form
    
    # 入力されていない項目を入力
    if self.title.blank?
      self.title = "無念"
    end
    
    if self.name.blank?
      self.name = "としあき"
    end
    
    if self.comment.blank?
      self.comment = "ｷﾀ━━━(ﾟ∀ﾟ)━━━!!"
    end
    
    # HTMLタグを削除
#    self.title =  ActionView::Base.full_sanitizer.sanitize(self.title)
#    self.name = ActionView::Base.full_sanitizer.sanitize(self.name)
#    self.email = ActionView::Base.full_sanitizer.sanitize(self.email)
#    self.comment = ActionView::Base.full_sanitizer.sanitize(self.comment)
#    self.title = ActionView::Base.full_sanitizer.sanitize(self.title)
    
    self.delflag = false
    self.imgdelflag = false
    
    # 画像が添付された場合、サムネイルを作成
    if self.image.present?
      return create_thumbnail
    end
  end

  # private method
  def create_thumbnail
    
    # 画像サイズは縦横比を保持したまま 200x200以下にする
    begin
        original_image = Magick::Image.from_blob(self.image).shift
        
        # 長い方を元にする
        longer_one = [original_image.rows, original_image.columns].max
        
        thumbnail_image = original_image.resize(200.0 / longer_one)
        
        thumbnail_image.format = "JPEG"
        self.thumbnail = thumbnail_image.to_blob {self.quality = 90}
        
    rescue Magick::ImageMagickError, RuntimeError => ex
      self.errors.add(:thumbnail, "サムネイル画像の作成に失敗しました。")
      return false
    end
  end
  
end
