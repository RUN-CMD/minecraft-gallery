require 'sinatra'
require 'rmagick'
require 'fileutils'

class GalleryConfig
  def self.factory(system)
    ConfigAir.new if system == :air
  end
end

class ConfigAir < GalleryConfig
  def gallery_root
    File.join('images/gallery/screenshots/'.split('/') )
  end

  def thumbnails_root
    File.join('images/gallery/thumbnails/screenshots/'.split('/') )
  end

  def thumbnails_generator_root
    File.join('gallery/thumbnails/screenshots/'.split('/') )
  end
end

class ConfigPi < GalleryConfig
  def gallery_root
    File.join('/data/www/gallery/screenshots/'.split('/') )
  end

  def thumbnails_root
    FileUtils.mkdir_p(File.join('images/gallery/thumbnails/screenshots/'.split('/') ) ).first
  end

  def thumbnails_generator_root
    File.join('gallery/thumbnails/screenshots/'.split('/') )
  end
end

config = GalleryConfig.factory(:air)

get '/' do
 'slash'
end

get "/#{config.thumbnails_generator_root}/:filename" do
  filename = File.basename(params[:filename])
  thumbnail_size = '160x160'

  source_image_dir  = File.join('public', config.gallery_root)
  source_image_path = File.join('public', config.gallery_root, filename)

  FileUtils.mkdir_p(File.join('public', config.thumbnails_root) )
  destination_thumbnail_path = File.join('public', config.thumbnails_root, filename)

  unless File.exist?(destination_thumbnail_path)
    begin
      Magick::Image.read(source_image_path).first.tap do |img|
        img.resize_to_fit!(thumbnail_size)
        img.write(destination_thumbnail_path) do
          self.compression = Magick::ZipCompression if destination_thumbnail_path.match(/png$/)
        end
      end
    rescue Magick::ImageMagickError => e
      return e.message
    rescue => e
      return e.message
    end
  end

  redirect to(destination_thumbnail_path[6..-1])
end

get '/gallery' do
header = '<link rel="stylesheet" href="//blueimp.github.io/Gallery/css/blueimp-gallery.min.css">'

header += <<-eostyle
<style>
  .blueimp-gallery > .slides > .slide {
  }

  .blueimp-gallery > .slides > .slide > .slide-content {
  }
</style>
eostyle

filenames = `ls #{File.join('public', config.gallery_root)}`.split("\n")

filenames.select! do |filename|
  begin
    filename.split('-').first.to_i >= 2015
  rescue
    false
  end
end

links = []

filenames.each do |filename|


 links << '<a href="' + File.join(config.gallery_root, filename) + '" title="Banana" data-gallery>' +
          '<img src="' + File.join(config.thumbnails_generator_root, filename)  + '" alt="Banana">' +
          '</a>'
end

body = '<div id="links">' + links.join + '</div>'


  footer = <<-eos

<!-- The Bootstrap Image Gallery lightbox, should be a child element of the document body -->
<div id="blueimp-gallery" class="blueimp-gallery">
    <!-- The container for the modal slides -->
    <div class="slides"></div>
    <!-- Controls for the borderless lightbox -->
    <h3 class="title"></h3>
    <a class="prev">&lt;</a>
    <a class="next">&gt;</a>
    <a class="close">[x]</a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
    <!-- The modal dialog, which will be used to wrap the lightbox content -->
    <div class="modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" aria-hidden="true">&times;</button>
                    <h4 class="modal-title"></h4>
                </div>
                <div class="modal-body next"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default pull-left prev">
                        <i class="glyphicon glyphicon-chevron-left"></i>
                        Previous
                    </button>
                    <button type="button" class="btn btn-primary next">
                        Next
                        <i class="glyphicon glyphicon-chevron-right"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script src="//blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js"></script>
<script>
blueimp.Gallery(
  document.getElementById('links').getElementsByTagName('a'),
  {
    displayTransition: false,
    slideshowInterval: 1200,
	transitionSpeed: 1
  }
);
</script>

eos

  header + body + footer
end
