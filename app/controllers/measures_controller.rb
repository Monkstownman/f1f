class MeasuresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_measure, only: [:show, :edit, :update, :destroy]

  # GET /measures
  # GET /measures.json
  def index
    @measures = Measure.all

    @seriesWeightStr = "[ "
    @seriesSystolicBloodPressureStr = "[ "
    @seriesDiastolicBloodPressureStr = "[ "
    @seriesIVCDiameterMaxStr = "[ "
    @seriesIVCDiameterMinStr = "[ "
    @seriesHeartRateStr = "[ "
    @seriesREMStr = "[ "
    @seriesLightStr = "[ "
    @seriesDeepStr = "[ "
    @seriesSleepScoreStr = "[ "
    @seriesF1FStr = "[ "
    @seriesOpenAndClosedStr = "[ "
    @seriesMotionStr = "[ "
    @seriesTemperatureStr = "[ "

    #Calcuated measures
    @seriesIVCStr = "[ "
    user_thing_lookup_id = request.original_url.split('/measures.')[1].to_i
    @things = Thing.all
    thing_id = UserThingLookup.find(user_thing_lookup_id).thing_id
    thingname = @things.find(thing_id).thingname.to_s
    @measures = @measures.where(active: true).where(thingname: thingname).order(:datetime)

    Analytics.track(
        user_id: current_user.id,
        event: 'Viewed Measures',
        properties: {
            thingname: thingname,
            user_email: current_user.email,
            datetime: DateTime.now
        })

    # Remove measures which are inactive
    @measures.all.each do |measure|
      @subject = measure.title
      @comment = measure.comment
      @corresponding_comment = ""
      @status = 0
      @id = measure.id
      unless @subject.include? "Invalid"
        @subjectJSON = JSON.parse(@subject.to_s)
        @seriesPartStr = ""
        if @subjectJSON["measures"][0]["name"] == "Weight"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesWeightStr = @seriesWeightStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"


        elsif @subjectJSON["measures"][0]["name"] == "ivc_diameter_max"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          @corresponding_ivc_diameter_min = @measures.where(active: true).where(name: "ivc_diameter_min").where(datetime: @datetime).first
          @corresponding_subject = @corresponding_ivc_diameter_min.title
          @corresponding_subjectJSON = JSON.parse(@corresponding_subject.to_s)
          @corresponding_value = @corresponding_subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          if !@measures.where(name: 'alert').where(value: measure.title).first.nil?
            @status = 1
          end
          if !@measures.where(name: 'acknowledgement').where(value: measure.title).first.nil?
             @status = 2
           end
          if @status == 0
            @seriesIVCDiameterMaxStr = @seriesIVCDiameterMaxStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          elsif @status == 1
            @seriesIVCDiameterMaxStr = @seriesIVCDiameterMaxStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {fillColor: '#00FF00', radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          else
            @seriesIVCDiameterMaxStr = @seriesIVCDiameterMaxStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {fillColor: '#FF0000', radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          end
          @ivc_value = (@value.to_f - @corresponding_value.to_f) / @value.to_f*100
          @seriesIVCStr = @seriesIVCStr + "{name: '" + @corresponding_comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @ivc_value.to_i.to_s + "   },"








        elsif @subjectJSON["measures"][0]["name"] == "ivc_diameter_min"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesIVCDiameterMinStr = @seriesIVCDiameterMinStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == "Systolic Blood Pressure"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesSystolicBloodPressureStr = @seriesSystolicBloodPressureStr + "{name: '" + '' + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == "Diastolic Blood Pressure"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesDiastolicBloodPressureStr = @seriesDiastolicBloodPressureStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == "Heart Rate"
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesHeartRateStr = @seriesHeartRateStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif (@subjectJSON["measures"][0]["name"] == "REMEpochs")
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = ((measure.value).to_i/2*1000*60).to_s
          if (@comment.to_s.blank? == false)
            @commentPresent = true
          else
            @commentPresent = false
          end
          @seriesREMStr = @seriesREMStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", dataLabels: {enabled: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif (@subjectJSON["measures"][0]["name"] == "LightEpochs")
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = ((measure.value).to_i/2*1000*60).to_s
          if (@comment.to_s.blank? == false)
            @commentPresent = true
          else
            @commentPresent = false
          end
          @seriesLightStr = @seriesLightStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", dataLabels: {enabled: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif (@subjectJSON["measures"][0]["name"] == "DeepEpochs")
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = ((measure.value).to_i/2*1000*60).to_s
          if (@comment.to_s.blank? == false)
            @commentPresent = true
          else
            @commentPresent = false
          end
          @seriesDeepStr = @seriesDeepStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", dataLabels: {enabled: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif (@subjectJSON["measures"][0]["name"] == "SleepScore")
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"]
          if (@comment.to_s.blank? == false)
            @commentPresent = true
          else
            @commentPresent = false
          end
          @seriesSleepScoreStr = @seriesSleepScoreStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", dataLabels: {enabled: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == 'F1F'
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"].tr(',', '')
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          if (@datetime > Date.today - 7.days)
            @seriesF1FStr = @seriesF1FStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          end
        elsif @subjectJSON["measures"][0]["name"] == 'Temperature'
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"].tr(',', '')
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesTemperatureStr = @seriesTemperatureStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == 'OpenAndClosed'
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"].tr(',', '')
          if @value =="0"
            @oppositeValue = "1"
          else
            @oppositeValue = "0"
          end
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          @seriesOpenAndClosedStr = @seriesOpenAndClosedStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @oppositeValue + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          @seriesOpenAndClosedStr = @seriesOpenAndClosedStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
        elsif @subjectJSON["measures"][0]["name"] == 'Motion'
          @datetime = DateTime.parse(@subjectJSON["measures"][0]["time"])
          @value = @subjectJSON["measures"][0]["value"].tr(',', '')
          if (@comment.to_s.blank? == false)
            @commentPresent = 8
          else
            @commentPresent = 4
          end
          if (@datetime > Date.today - 7.days)
            @seriesMotionStr = @seriesMotionStr + "{name: '" + @comment + "', x: Date.UTC(" + @datetime.year.to_s + ", " + (@datetime.month - 1).to_s + ", " + @datetime.day.to_s + ", " + @datetime.hour.to_s + ", " + @datetime.minute.to_s + ", " + @datetime.second.to_s + "), y: " + @value + ", marker: {radius: " + @commentPresent.to_s + "} , events: { click: function() { window.open('../measures/" + @id.to_s + "/edit','_self'); }} },"
          end
        end
      end
    end

    # Remove last , from string
    @seriesWeightStr = @seriesWeightStr.gsub(/.{1}$/, '')
    @seriesWeightStr = @seriesWeightStr + "]"
    @seriesSystolicBloodPressureStr = @seriesSystolicBloodPressureStr.gsub(/.{1}$/, '')
    @seriesSystolicBloodPressureStr = @seriesSystolicBloodPressureStr + "]"
    @seriesDiastolicBloodPressureStr = @seriesDiastolicBloodPressureStr.gsub(/.{1}$/, '')
    @seriesDiastolicBloodPressureStr = @seriesDiastolicBloodPressureStr + "]"
    @seriesIVCDiameterMaxStr = @seriesIVCDiameterMaxStr.gsub(/.{1}$/, '')
    @seriesIVCDiameterMaxStr = @seriesIVCDiameterMaxStr + "]"
    @seriesIVCDiameterMinStr = @seriesIVCDiameterMinStr.gsub(/.{1}$/, '')
    @seriesIVCDiameterMinStr = @seriesIVCDiameterMinStr + "]"
    @seriesHeartRateStr = @seriesHeartRateStr.gsub(/.{1}$/, '')
    @seriesHeartRateStr = @seriesHeartRateStr + "]"
    @seriesREMStr = @seriesREMStr.gsub(/.{1}$/, '')
    @seriesREMStr = @seriesREMStr + "]"
    @seriesLightStr = @seriesLightStr.gsub(/.{1}$/, '')
    @seriesLightStr = @seriesLightStr + "]"
    @seriesDeepStr = @seriesDeepStr.gsub(/.{1}$/, '')
    @seriesDeepStr = "" + @seriesDeepStr + "]"
    @seriesSleepScoreStr = @seriesSleepScoreStr.gsub(/.{1}$/, '')
    @seriesSleepScoreStr = "" + @seriesSleepScoreStr + "]"
    @seriesF1FStr = @seriesF1FStr.gsub(/.{1}$/, '')
    @seriesF1FStr = @seriesF1FStr + "]"
    @seriesOpenAndClosedStr = @seriesOpenAndClosedStr.gsub(/.{1}$/, '')
    @seriesOpenAndClosedStr = @seriesOpenAndClosedStr + "]"
    @seriesMotionStr = @seriesMotionStr.gsub(/.{1}$/, '')
    @seriesMotionStr = @seriesMotionStr + "]"
    @seriesTemperatureStr = @seriesTemperatureStr.gsub(/.{1}$/, '')
    @seriesTemperatureStr = @seriesTemperatureStr + "]"

    #Calculated measures
    @seriesIVCStr = @seriesIVCStr.gsub(/.{1}$/, '')
    @seriesIVCStr = @seriesIVCStr + "]"
  end

  # GET /measures/1
  # GET /measures/1.json
  def show
  end

  # GET /measures/new
  def new
    @measure = Measure.new
  end

  # GET /measures/1/edit
  def edit
  end

  # POST /measures
  # POST /measures.json
  def create
    @measure = Measure.new(measure_params)

    respond_to do |format|
      if @measure.save
        format.html { redirect_to @measure, notice: 'Measure was successfully created.' }
        format.json { render :show, status: :created, location: @measure }
      else
        format.html { render :new }
        format.json { render json: @measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /measures/1
  # PATCH/PUT /measures/1.json
  def update
    respond_to do |format|
      if @measure.update(measure_params)
        format.html { redirect_to @measure, notice: 'Measure was successfully updated.' }
        format.json { render :show, status: :ok, location: @measure }
      else
        format.html { render :edit }
        format.json { render json: @measure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measures/1
  # DELETE /measures/1.json
  def destroy
    @measure.destroy
    respond_to do |format|
      format.html { redirect_to measures_url, notice: 'Measure was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_measure
    @measure = Measure.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def measure_params
    params.require(:measure).permit(:title, :body, :datetime, :name, :value, :thing, :unit, :source, :comment, :active)
  end
end
