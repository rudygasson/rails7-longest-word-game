require 'open-uri'

class GamesController < ApplicationController
  VOWELS = %w(A E I O U)
  CONSONANTS = ('A'..'Z').to_a - VOWELS

  def new
    @letters = Array.new(5) { CONSONANTS.sample } + Array.new(5) { VOWELS.sample }
    @letters.shuffle!
    session[:grid] = @letters
    session[:start_time] = Time.now
  end

  def score
    @end_time = Time.now
    result = run_game(params[:word], session[:grid], session[:start_time].to_time, @end_time)
    @message = result[:message]
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : (attempt.size * (1.0 - time_taken / 60.0)).round(2)
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }

    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last

    result
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "Well done. You get #{score} points!"]
      else
        [0, "Sorry, '#{attempt}' is not an english word."]
      end
    else
      [0, "Nope, '#{attempt}' is not part of the letters grid."]
    end
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

end
