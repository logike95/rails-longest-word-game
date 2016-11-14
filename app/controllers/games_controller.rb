class GamesController < ApplicationController

  def game
      @grid = generate_grid(9)
      @start_time = Time.now

  end


  def score
    @attempt = params[:sentence] #params = value du name
    @grid = params[:grid]
    @start_time = Time.new(params[:start_time])
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  def generate_grid(size)
    array = []
    size.times do
      array << ('A'..'Z').to_a.sample
    end
      return array
  end

  def included?(guess, grid)
  guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end


  def score_and_message(attempt, translation, grid, time)
  if included?(attempt.upcase, grid)
    if translation
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
  end

  def get_translation(word) # faire un lien avec le formulaire pour word
      api_key = "b5e7e1df-752d-4295-8171-15c21ddbab29"
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
  end

  def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }
  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
  attempt, result[:translation], grid, result[:time])
  result
  end






end
