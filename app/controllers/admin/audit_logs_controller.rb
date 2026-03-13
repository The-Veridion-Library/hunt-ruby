class Admin::AuditLogsController < Admin::BaseController
  PER_PAGE = 50

  def index
    @admin_users = User.where(role: "admin").order(:username)
    @action_types = AuditLog.distinct.order(:action).pluck(:action)

    @audit_logs = AuditLog.includes(:user).order(created_at: :desc)
    @audit_logs = @audit_logs.where(action: params[:action_type]) if params[:action_type].present?
    @audit_logs = @audit_logs.where(user_id: params[:admin_user_id]) if params[:admin_user_id].present?
    @audit_logs = @audit_logs.where(created_at: from_date.beginning_of_day..) if from_date
    @audit_logs = @audit_logs.where(created_at: ..to_date.end_of_day) if to_date

    @page = [params.fetch(:page, 1).to_i, 1].max
    @total_count = @audit_logs.count
    @audit_logs = @audit_logs.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @has_previous = @page > 1
    @has_next = (@page * PER_PAGE) < @total_count
  end

  helper_method :resource_link_data

  private

  def from_date
    return @from_date if defined?(@from_date)

    @from_date = parse_date(params[:from_date])
  end

  def to_date
    return @to_date if defined?(@to_date)

    @to_date = parse_date(params[:to_date])
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def resource_link_data(log)
    path = case log.resource_type
           when "User"
             admin_user_path(log.resource_id)
           when "Book"
             admin_book_path(log.resource_id)
           when "Label"
             admin_label_path(log.resource_id)
           when "Location"
             admin_location_path(log.resource_id)
           when "Badge"
             admin_badge_path(log.resource_id)
           else
             nil
           end

    ["#{log.resource_type} ##{log.resource_id}", path]
  end
end
