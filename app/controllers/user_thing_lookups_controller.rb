class UserThingLookupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_user_thing_lookup, only: [:show, :edit, :update, :destroy]

  # GET /user_thing_lookups
  # GET /user_thing_lookups.json
  def index
    @user_thing_lookups = UserThingLookup.where(user_id: current_user)

    start_date = Date.parse "2017-03-12 12:00:00 +0100"
    end_date = Date.today()
    @dateDifference =  (end_date - start_date).to_i + 2
  end

  # GET /user_thing_lookups/1
  # GET /user_thing_lookups/1.json
  def show
  end

  # GET /user_thing_lookups/new
  def new
    @user_thing_lookup = UserThingLookup.new
  end

  # GET /user_thing_lookups/1/edit
  def edit
  end

  # POST /user_thing_lookups
  # POST /user_thing_lookups.json
  def create
    @user_thing_lookup = UserThingLookup.new(user_thing_lookup_params)

    respond_to do |format|
      if @user_thing_lookup.save
        format.html { redirect_to @user_thing_lookup, notice: 'User thing lookup was successfully created.' }
        format.json { render :show, status: :created, location: @user_thing_lookup }
      else
        format.html { render :new }
        format.json { render json: @user_thing_lookup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_thing_lookups/1
  # PATCH/PUT /user_thing_lookups/1.json
  def update
    respond_to do |format|
      if @user_thing_lookup.update(user_thing_lookup_params)
        format.html { redirect_to @user_thing_lookup, notice: 'User thing lookup was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_thing_lookup }
      else
        format.html { render :edit }
        format.json { render json: @user_thing_lookup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_thing_lookups/1
  # DELETE /user_thing_lookups/1.json
  def destroy
    @user_thing_lookup.destroy
    respond_to do |format|
      format.html { redirect_to user_thing_lookups_url, notice: 'User thing lookup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_thing_lookup
      @user_thing_lookup = UserThingLookup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_thing_lookup_params
      params.require(:user_thing_lookup).permit(:user_id, :thing_id)
    end
end
