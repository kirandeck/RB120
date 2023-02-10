class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |"
    puts ""
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def computer_smart_move(marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      markers = squares.map(&:marker)
      if markers.count(marker) == 2
        line.each { |key| return key if @squares[key].unmarked? }
      end
    end
    nil
  end

  def square_five_available?
    open_squares = unmarked_keys
    open_squares.include?(5)
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  UP_TO_HOW_MANY_WINS = 5

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  attr_reader :board, :human, :computer, :human_name, :computer_name, :score

  def initialize
    @board = Board.new
    @human_name = retrieve_human_name
    @computer_name = generate_computer_name
    @human = Player.new(choose_marker)
    @computer = Player.new(other_marker)
    display_rules
    @current_marker = who_goes_first?
    @score = { human: 0, computer: 0 }
  end

  def retrieve_human_name
    name = ''
    loop do
      puts "What is your name?"
      name = gets.chomp.capitalize.strip
      break unless name == ''
      puts "Invalid input."
    end
    name
  end

  def generate_computer_name
    ['Bert', 'Sally', 'Marvin', 'Karen'].sample
  end

  def choose_marker
    answer = nil
    loop do
      puts "What marker would you like to be? (x/o)"
      answer = gets.chomp.downcase
      break if answer == 'x' || answer == 'o'
      puts "Invalid input."
    end
    answer == 'x' ? 'X' : 'O'
  end

  def other_marker
    human.marker == 'X' ? 'O' : 'X'
  end

  def display_rules
    puts ""
    puts "The winner of each game will have the first move in the next game."
    puts "If there is a tie, the honors will alternate."
    puts ""
    sleep(3)
  end

  def display_welcome_message
    puts "Hello #{@human_name}! Welcome to tic tac toe!"
    puts ""
    puts "The first player to reach 5 wins will win the match!"
    puts ""
    sleep(3)
  end

  def display_goodbye_message
    puts "Thanks for playing tic tac toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're a #{human.marker}, #{@computer_name} is #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(keys, punctuation = ", ", word = "or")
    case keys.size
    when 1
      keys.join
    when 2
      keys.join(" #{word} ")
    else
      keys[-1] = word + ' ' + keys[-1].to_s
      keys.join(punctuation)
    end
  end

  def human_moves
    square = nil
    puts "Choose a square #{joinor(board.unmarked_keys)}:"
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Invalid input."
    end
    board[square] = human.marker
  end

  def computer_moves
    if board.square_five_available?
      square_five_assignment
    elsif board.computer_smart_move(computer.marker)
      computer_offense_assignment
    elsif board.computer_smart_move(human.marker)
      computer_defense_assignment
    else
      random_square_assignment
    end
  end

  def square_five_assignment
    board[5] = computer.marker
  end

  def computer_offense_assignment
    board[board.computer_smart_move(computer.marker)] = computer.marker
  end

  def computer_defense_assignment
    board[board.computer_smart_move(human.marker)] = computer.marker
  end

  def random_square_assignment
    board[board.unmarked_keys.sample] = computer.marker
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "#{@computer_name} won!"
    else
      puts "It's a tie!"
    end
  end

  def update_score_and_marker
    case board.winning_marker
    when human.marker
      @score[:human] += 1
      @current_marker = human.marker
    when computer.marker
      @score[:computer] += 1
      @current_marker = computer.marker
    end
  end

  def display_current_score
    puts "The current score is:"
    puts "#{human_name}:#{score[:human]} | #{computer_name}:#{score[:computer]}"
  end

  def display_final_score
    puts "The final score is:"
    puts "#{human_name}:#{score[:human]} | #{computer_name}:#{score[:computer]}"
    sleep(2)
  end

  def wins_reached?
    @score.each { |_, v| return true if v >= UP_TO_HOW_MANY_WINS }
    false
  end

  def continue_playing?
    answer = nil
    loop do
      puts "Would you like to continue playing? (y/n)"
      answer = gets.chomp.downcase
      break if %(y n).include?(answer)
      puts "Invalid input."
    end
    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset
    board.reset
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def who_goes_first?
    answer = nil
    loop do
      puts "Who shall go first? you(y), opponent(o), random(r)"
      answer = gets.chomp.downcase
      break if answer == 'y' || answer == 'o' || answer == 'r'
      puts "Invalid input."
    end
    assign_first_move(answer)
  end

  def assign_first_move(answer)
    @current_marker = if answer == 'y'
                        human.marker
                      elsif answer == 'o'
                        computer.marker
                      else
                        [human.marker, computer.marker].sample
                      end
  end

  def game_play
    display_board
    player_move
    display_result
    update_score_and_marker
  end

  def main_game
    loop do
      game_play
      break if wins_reached?
      display_current_score
      break unless continue_playing?
      reset
      display_play_again_message
    end
    display_final_score
  end
end

game = TTTGame.new
game.play
