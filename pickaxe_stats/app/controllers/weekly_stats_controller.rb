class WeeklyStatsController < ApplicationController
  before_action :set_weekly_stat, only: [:show, :edit, :update, :destroy]

  # GET /weekly_stats
  # GET /weekly_stats.json
  def index
    @weekly_stats = WeeklyStat.all.order(commit_date: :desc)
  end

  # GET /weekly_stats/1
  # GET /weekly_stats/1.json
  def show
  end

  # GET /weekly_stats/new
  def new
    @weekly_stat = WeeklyStat.new
  end

  # GET /weekly_stats/1/edit
  def edit
  end

  # POST /weekly_stats
  # POST /weekly_stats.json
  def create
    @weekly_stat = WeeklyStat.new(weekly_stat_params)

    respond_to do |format|
      if @weekly_stat.save
        format.html { redirect_to @weekly_stat, notice: 'Weekly stat was successfully created.' }
        format.json { render :show, status: :created, location: @weekly_stat }
      else
        format.html { render :new }
        format.json { render json: @weekly_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weekly_stats/1
  # PATCH/PUT /weekly_stats/1.json
  def update
    respond_to do |format|
      if @weekly_stat.update(weekly_stat_params)
        format.html { redirect_to weekly_stats_path, notice: 'Weekly stat was successfully updated.' }
        format.json { render :show, status: :ok, location: @weekly_stat }
      else
        format.html { render :edit }
        format.json { render json: @weekly_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weekly_stats/1
  # DELETE /weekly_stats/1.json
  def destroy
    @weekly_stat.destroy
    respond_to do |format|
      format.html { redirect_to weekly_stats_url, notice: 'Weekly stat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  
  def most_recent
    @weekly_stat = WeeklyStat.where(weekend_number: params[:weekend_number]).first
    redirect_to @weekly_stat
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weekly_stat
      @weekly_stat = WeeklyStat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weekly_stat_params
      params.require(:weekly_stat).permit(:week_number, :weekend_number, :launched_at, :shutdown_at)
    end
end
