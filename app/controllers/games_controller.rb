class GamesController < ApplicationController
  VOWELS = %w(A E I O U)
  CONSONANTS = ('A'..'Z').to_a - VOWELS

  def new
    @letters = Array.new(5) { CONSONANTS.sample } + Array.new(5) { VOWELS.sample }
    @letters.shuffle!
  end

  def score
  end
end
