class Log
  attr_reader :logger

  def initialize (fileName = nil, type = nil)
    Log.open_log(fileName, type)
  end

  def open_newLog (fileName = nil, type = nil)
    Log.open_log(fileName, type)
  end

  def self.open_log (fileName = nil, type = nil)
    fileName = (fileName ? "_#{fileName}" : '')
    type = (type ? "_#{type}" : '')
    appendName = fileName + type
    @logger = Logger.new('/var/log/project/syslog' + appendName + '.log')
  end

  def self.makeMessage(controller, parameter = nil, message = nil)
    token = ' :: '
    controllerName = '[' + controller.class.name + ']'
    if controller.action_name != nil
    	actionName = '[' + controller.action_name.capitalize + ']'
    else
        actionName = '[' + caller[1].split.last + ']'
    end
    message = message ? token + '"' + message + '"' : ""
    if parameter != nil
      if parameter.class != String
        parameter = parameter.to_s
      end
      if parameter != ""
        parameter = token + parameter + message
      else
        parameter = message
      end
    else
      parameter = message
    end
    returnMessage = controllerName + token + actionName + parameter
    return returnMessage
  end

  def debug(controller, parameter = nil, message = nil)
    Log.debug(controller, parameter, message)
  end

  def info(controller, parameter = nil, message = nil)
    Log.info(controller, parameter, message)
  end

  def fatal(controller, parameter = nil, message = nil)
    Log.fatal(controller, parameter, message)
  end

  def self.debug(controller, parameter = nil, message = nil)
    @logger ||= Log.open_log
    log_msg = Log.makeMessage(controller, parameter, message)
    @logger.debug(log_msg)
  end

  def self.info(controller, parameter = nil, message = nil)
    @logger ||= Log.open_log
    log_msg = Log.makeMessage(controller, parameter, message)
    @logger.info(log_msg)
  end

  def self.fatal(controller, parameter = nil, message = nil)
    @logger ||= Log.open_log
    log_msg = Log.makeMessage(controller, parameter, message)
    @logger.fatal(log_msg)
  end

end
