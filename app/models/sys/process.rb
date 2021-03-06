# encoding: utf-8
class Sys::Process < ActiveRecord::Base
  include Sys::Model::Base

  self.table_name = 'sys_processes'

  attr_accessor :title

  def status
    labels = {
      'running' => "実行中",
      'closed'  => "完了",
      'stop'    => "停止"
    }
    labels[state] || state
  end
  
  def progress
    return "100" if state == 'closed' && total.to_i == 0
    return "0" if total.to_i < 1 || current.to_i < 1
    ret = (current.to_f/total * 100).round
    return ret > 100 ? 100 : ret
  end

  def self.lock(attrs = {})
    raise 'lock name is blank.' if attrs[:name].blank?

    proc = find_by(name: attrs[:name])

    if proc
      # if proc.closed_at.nil?
      if proc.state == 'running'
        kill = attrs[:time_limit] || 0
        return false if (proc.updated_at.to_i + kill) > Time.now.to_i
      end
    end
    attrs.delete(:time_limit)

    proc ||= new
    proc.created_at  = DateTime.now
    proc.updated_at  = DateTime.now
    proc.started_at  = DateTime.now
    proc.closed_at   = nil
    proc.user_id     = Core.user ? Core.user.id : nil
    proc.state       = 'running'
    proc.total       = 0
    proc.current     = 0
    proc.success     = 0
    proc.error       = 0
    proc.message     = nil
    proc.interrupt   = nil
    proc.attributes  = attrs
    proc.save
    proc
  end

  def unlock
    self.closed_at = DateTime.now
    self.state     = 'closed'
    save
  end

  def interrupted?
    self.class.uncached do
      item = self.class.find_by(id: id)
      self.interrupt = item.interrupt
      return item.interrupt.blank? ? nil : item.interrupt
    end
  end
end
