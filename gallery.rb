require 'sinatra'
require 'dragonfly'
require 'rmagick'
require 'fileutils'

get '/' do
 'slash'
end

get '/gallery/thumbnails/screenshots/:filename' do
  filename = File.basename(params[:filename])
  source_image_dir  = File.join('', 'data', 'www', 'gallery', 'screenshots')
  source_image_path = File.join('', 'data', 'www', 'gallery', 'screenshots', filename)

  destination_thumbnail_dir  = FileUtils.mkdir_p(File.join('public', 'images', 'gallery', 'thumbnails', 'screenshots') ).first
  destination_thumbnail_path = File.join(destination_thumbnail_dir, filename)

  unless File.exist?(destination_thumbnail_path)
    #  Dragonfly.app.fetch_file(source_image_path).thumb('320x180').to_response(env)
    begin
      Magick::Image.read(source_image_path).first.tap do |img|
        img.resize_to_fit!(320, 320)
        img.write(destination_thumbnail_path) { self.quality = 0.1 }
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
'<link rel="stylesheet" href="//10.0.0.3:25571/gallery/css/bootstrap-image-gallery.min.css">' +
'<style>.blueimp-gallery > .slides > .slide > .slide-content { display: none; } </style>'


filenames = `ls /data/www/gallery/screenshots/`.split("\n")

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
<script src="//blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js"></script>
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
