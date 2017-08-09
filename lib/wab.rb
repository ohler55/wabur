# For use/testing when no gem is installed
$LOAD_PATH.unshift __dir__

# Web Application Builder
module WAB
end

require 'wab/data'
require 'wab/model'
require 'wab/shell'
require 'wab/uuid'
require 'wab/version'
