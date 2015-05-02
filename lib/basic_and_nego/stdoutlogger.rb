module BasicAndNego
  class StdOutLogger
    def info(progname = nil, &block)
      puts progname
      yield block if block_given?
    end
    def debug(progname = nil, &block)
      puts progname
      yield block if block_given?
    end
    def warn(progname = nil, &block)
      puts progname
      yield block if block_given?
    end
    def error(progname = nil, &block)
      puts progname
      yield block if block_given?
    end
    def fatal(progname = nil, &block)
      puts progname
      yield block if block_given?
    end
  end
end

