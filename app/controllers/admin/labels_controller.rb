class Admin::LabelsController < Admin::BaseController
  before_action :set_label, only: [:show, :update, :destroy]

  def index
    @labels = Label.includes(:book, :location, :user).order(created_at: :desc)
    @labels = @labels.where(status: params[:status]) if params[:status].present?
  end

  def show; end

  def update
    previous_status = @label.status

    if @label.update(label_params)
      if previous_status != @label.status && @label.status == 'invalidated'
        AuditLogService.log(
          user: current_user,
          action: 'force_invalidated_label',
          resource: @label,
          details: { from: previous_status, to: @label.status },
          request: request
        )
      end

      redirect_to admin_label_path(@label), notice: "Label status updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @label.destroy

    AuditLogService.log(
      user: current_user,
      action: 'deleted_label',
      resource: @label,
      request: request
    )

    redirect_to admin_labels_path, notice: "Label deleted."
  end

  private

  def set_label
    @label = Label.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:status)
  end
end