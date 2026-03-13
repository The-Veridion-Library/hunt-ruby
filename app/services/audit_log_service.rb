class AuditLogService
  def self.log(user:, action:, resource:, details: {}, request: nil)
    return if resource.nil?

    AuditLog.create!(
      user: user,
      action: action,
      resource_type: resource.class.name,
      resource_id: resource.id,
      details: details.presence || {},
      ip_address: request&.remote_ip
    )
  end
end
