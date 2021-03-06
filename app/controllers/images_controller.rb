class ImagesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
    @categories = Category.all
  end

  # GET /images/1/edit
  def edit
    @checked_cates = Categorization.where(image_id: params[:id]).map {|cate| cate.category_id}
    @categories = Category.all
    @image_files = Imagefile.where(image_id: params[:id])
  end

  # POST /images
  # POST /images.json
  def create

    @image = Image.new(image_params)
    @image.user = current_user
    # @image.image_file_path = image_file_params

    respond_to do |format|

      if @image.save!

        # create the catelization item
        @cate_ids = image_cate_params

        @cate_ids.each do |cate_id| 
          @categorization = Categorization.new()
          @categorization.category = Category.find(cate_id)
          @categorization.image = @image
          if @categorization.save!
              p "Sucess"
          else
              p "Fail to add category!"
          end
        end

          image_path_params.each do |img_path|

            # puts img_path

            imagefile = Imagefile.new(image_file_path: img_path) 
            
            imagefile.image = @image

            if imagefile.save!
              size = imagefile.image_size['width'].to_s + "*" + imagefile.image_size['height'].to_s
              puts "Size: " + size
              imagefile.size = size
              imagefile.save!
            end
          end


        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update    
    respond_to do |format|
      if @image.update(image_params)
        # puts "Image Array:"
        # puts params[:image][:image_file_path]

        # destroy the current categories
        Categorization.where(image_id: @image.id).destroy_all

        @cate_ids = image_cate_params
        @cate_ids.each do |cate_id| 
          @categorization = Categorization.new()
          @categorization.category = Category.find(cate_id)
          @categorization.image = @image
          if @categorization.save!
              p "Sucess"
          else
              p "Fail to add category!"
          end
        end

        if image_path_params
          image_path_params.each do |img_path|

            imagefile = Imagefile.new(image_file_path: img_path)           
            imagefile.image = @image

            if imagefile.save!
              size = imagefile.image_size['width'].to_s + "*" + imagefile.image_size['height'].to_s
              puts "Size: " + size
              imagefile.size = size
              imagefile.save!
            end
          end
        end

        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      # params.require(:image).permit(:name, :desc, :author, :verse, :image_file_path)
      params.require(:image).permit(:name, :desc, :author, :verse)
    end

    def image_path_params
      params[:image][:image_file_path]
    end

    def image_cate_params
      params[:cate_ids]
    end

end
