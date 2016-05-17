module Plotline
  module Import
    module Handlers
      class Base
        def initialize(runner)
          @runner = runner
        end

        def supported_file?(filename)
          raise NotImplementedError
        end

        private

        def log(msg)
          Plotline.configuration.logger.info(msg)
        end
      end
    end
  end
end
