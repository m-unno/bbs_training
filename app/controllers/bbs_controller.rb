# coding: utf-8

class BbsController < ApplicationController
  
  def index
    @new_thread = BbsThread.new
    @view_page = 0
    
    if session[:user_id].present?
      @bbs_threads = BbsThread.order("id DESC").limit(10)
      @total_page = page_count(BbsThread.count)
    else
      @bbs_threads = BbsThread.order("id DESC").where(delflag: false).limit(10)
      @total_page = page_count(BbsThread.where(delflag: false).count)
    end
  end
  
  def show
    @new_thread = BbsThread.new
    @view_page = params[:id].to_i
    
    if session[:user_id].present?
      @bbs_threads = BbsThread.order("id DESC").offset(params[:id].to_i*10).limit(10)
      @total_page = page_count(BbsThread.count)
    else
      @bbs_threads = BbsThread.order("id DESC").where(delflag: false).offset(params[:id].to_i*10).limit(10)
      @total_page = page_count(BbsThread.where(delflag: false).count)
    end
    
    render "index"
  end
  
  # ページ番号は1から
  def page_count(total_record)
    page = total_record / 10
    
    if (total_record % 10) != 0
      page += 1
    end
    
    return page
  end
  def create
    
    add_thread = BbsThread.new(params[:bbs_thread])
    
    if add_thread.save
      flash[:notice] = "投稿が完了しました"
    else
      flash[:notice] = add_thread.errors.full_messages[0]
    end
    
    redirect_to :action => "index"
  end
  
  def deletes

    # 削除対象の取り出し
    delete_items = params[:checked_items]
    
    if delete_items.blank?
      flash[:notice] = "削除対象が選択されていません。"
      redirect_to :action => "index"
      return
    end
    
    if params[:delete_key].blank?
      flash[:notice] = "削除キーが入力されていません。"
      redirect_to :action => "index"
      return
    end
    
    begin
      delete_thread = BbsThread.find(delete_items.keys, :select => "id, delkey, delflag, imgdelflag")
#      delete_thread = BbsThread.find(delete_items.keys)
      
      delete_thread.each do |dt|
        if dt.delkey != params[:delete_key]
          flash[:notice] = "削除キーが一致しないため削除出来ません。"
          redirect_to :action => "index"
          return
        end
      end
        
      BbsThread.transaction do
        
        delete_thread.each do |dt|

          # フラグをセットする
          if params[:image_only]
  #          dt.delflag = true;
            dt.update_attributes!(:imgdelflag => true)
          else
            dt.update_attributes!(:delflag => true, :imgdelflag => true)
          end
    #        dt.imgdelflag = true;
        end
      end
      
      flash[:notice] = "削除が完了しました"
    rescue
      flash[:notice] = delete_thread.errors.full_messages[0]
    end
  
    # 画像のみ以外の場合
#    if params[:image_only]
#      result = delete_thread.update_all("imgdelflag = 'true'", delete_items.keys)
#    else 
#      result = delete_thread.update_all("delflag = 'true', imgdelflag = 'true'", delete_items.keys)
#    end
      
#    if delete_thread.save
#      flash[:notice] = "削除が完了しました"
#    else
#      flash[:notice] = add_thread.errors.full_messages[0]
#    end
    
    redirect_to :action => "index"
  end
  
  def destroys
    
    # 削除対象の取り出し
    delete_items = params[:checked_items]
    
    if delete_items.blank?
      flash[:notice] = "削除対象が選択されていません。"
      redirect_to :action => "index"
      return
    end
    
    begin
      BbsThread.transaction do
        
        delete_thread = BbsThread.find(delete_items.keys, :select => "id, comment, image, thumbnail, delflag, imgdelflag")
        
        delete_thread.each do |dt|
          
          if params[:image_only]
            if dt.image.present?
              add_comment = "<この画像は管理者により削除されました>\n" + dt.comment
              dt.update_attributes!(:comment => add_comment, :image => nil, :thumbnail => nil, :delflag => false, :imgdelflag => false)
            end
          else
            dt.destroy
          end
        end
      end
      
      flash[:notice] = "削除が完了しました"
    rescue
#      flash[:notice] = delete_thread.errors.full_messages[0]
    end
    
    redirect_to :action => "index"
  end
  
  
  def image
    image_data = BbsThread.find(params[:id], :select => "image, content_type")
    
    if image_data.image.present?
      send_data(image_data.image, :disposition => "inline", :type => image_data.content_type)
    else
      render_404
    end
  end
  
  def thumbnail
    thumbnail_data = BbsThread.find(params[:id], :select => "thumbnail")
    
    if thumbnail_data.thumbnail.present?
      send_data(thumbnail_data.thumbnail, :disposition => "inline", :type => "image/jpeg")
    else
      render_404
    end
  end
  
  # 404エラー
  def render_404()
#    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false, :content_type => 'text/html'
    render :text => "<h1>404 File not found</h1>", :status => 404, :layout => false
  end
end
