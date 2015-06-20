require 'sinatra'
require 'dragonfly'
require 'rmagick'
require 'fileutils'

get '/' do
 'slash'
end

get '/gallery/thumbnails/screenshots/:filename' do
  filename = File.basename(params[:filename])
  thumbnail_size = '160x160'

  source_image_dir  = File.join('', 'data', 'www', 'gallery', 'screenshots')
  source_image_path = File.join('', 'data', 'www', 'gallery', 'screenshots', filename)

  destination_thumbnail_dir  = FileUtils.mkdir_p(File.join('public', 'images', 'gallery', 'thumbnails', thumbnail_size, 'screenshots') ).first
  destination_thumbnail_path = File.join(destination_thumbnail_dir, filename).gsub(/png$/, 'jpg')

  unless File.exist?(destination_thumbnail_path)
    #  Dragonfly.app.fetch_file(source_image_path).thumb('320x180').to_response(env)
    begin
      Magick::Image.read(source_image_path).first.tap do |img|
        img.resize_to_fit!(thumbnail_size)
        img.format = 'JPEG'
        img.write(destination_thumbnail_path) do
          self.quality = 50
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
header = '<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">' +
'<link rel="stylesheet" href="//blueimp.github.io/Gallery/css/blueimp-gallery.min.css">' +
'<link rel="stylesheet" href="//10.0.0.3:25571/gallery/css/bootstrap-image-gallery.min.css">'

header += <<-eostyle
<style>
  .blueimp-gallery > .slides > .slide {

  -webkit-transition-timing-function: cubic-bezier(0.0, 0.0, 0.000, 0.000); 
     -moz-transition-timing-function: cubic-bezier(0.0, 0.0, 0.000, 0.000); 
      -ms-transition-timing-function: cubic-bezier(0.0, 0.0, 0.000, 0.000); 
       -o-transition-timing-function: cubic-bezier(0.0, 0.0, 0.000, 0.000); 
          transition-timing-function: cubic-bezier(0.0, 0.0, 0.000, 0.000);

  }

  .blueimp-gallery > .slides > .slide > .slide-content {  
  -webkit-transition: opacity 0s linear;
     -moz-transition: opacity 0s linear;
      -ms-transition: opacity 0s linear;
       -o-transition: opacity 0s linear;
          transition: opacity 0s linear;
  }
</style>
eostyle

filenames = `ls /data/www/gallery/screenshots/`.split("\n")
filenames.select! do |filename|
  begin
    filename.split('-').first.to_i >= 2015
  rescue
    false
  end
end

links = []

filenames.each do |filename|


 links << '<a href="' + "http://10.0.0.3:25571/gallery/screenshots/#{filename}" + '" title="Banana" data-gallery>' +
        '<img src="' + "http://10.0.0.3:4567/gallery/thumbnails/screenshots/#{filename}"  + '" alt="Banana">' +
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
<script src="//blueimp.github.io/Gallery/js/jquery.blueimp-gallery.js"></script>
<script>
blueimp.Gallery(
  document.getElementById('links').getElementsByTagName('a'),
  {
    displayTransition: false,
    slideshowTransitionSpeed: 0
  }
);
</script>

eos

  header + body + footer
end
