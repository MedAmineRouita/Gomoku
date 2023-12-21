#!/usr/bin/env ruby

class GameBoard
  def initialize(size = 0)
    @winner = nil
    @last_player = nil
    @board_size = size
    @game_board = Array.new(size) { Array.new(size, 0) }
    @move_list = []
    @last_move = nil
    @is_game_over = false
    @move_count = 0
  end

  def get_first_available
    @board_size.times do |i|
      @board_size.times do |j|
        return [i, j] if @game_board[i][j] == 0
      end
    end
    [-1, -1]
  end

  def reset_game_board
    @game_board = Array.new(@board_size) { Array.new(@board_size, 0) }
  end

  def default_move
    x, y = get_first_available
    raise 'ERROR' if x < 0 || y < 0
    set_game_move([x, y, 1])
    "#{x},#{y}"
  end

  def get_best_move
    move = find_winning_move(1)
    return set_and_return_move(move) if move
    move = find_winning_move(2)
    return set_and_return_move(move) if move
    default_move
  end

  def set_game_move(move)
    raise 'ERROR' unless move.length == 3
    x, y, player = move.map(&:to_i)
    if (x < 0 || y < 0 || x >= @board_size || y >= @board_size || player < 1 || player > 2)
      puts "ERROR"
      $stdout.flush
      exit 84
    end
    raise 'ERROR' unless @game_board[x][y] == 0
    @game_board[x][y] = player
    @move_list << move
  end
  
  def set_board_size(size)
    @board_size = size
    @game_board = Array.new(size) { Array.new(size, 0) }
  end

  def get_board_size()
    @board_size
  end

  def debug
    @game_board.each { |row| puts row $stdout.flush }
  end

  def find_winning_move(player)
    @board_size.times do |i|
      @board_size.times do |j|
        if @game_board[i][j] == 0
          return [i, j] if winning_move?(i, j, player)
        end
      end
    end
    nil
  end

  def winning_move?(row, col, player)
    directions = [[0, -1], [0, 1], [-1, 0], [1, 0], [-1, 1], [1, -1], [-1, -1], [1, 1]]
    directions.each_slice(2) do |(row_delta1, col_delta1), (row_delta2, col_delta2)|
      return true if check_direction(row, col, player, row_delta1, col_delta1) + check_direction(row, col, player, row_delta2, col_delta2) >= 4
    end
    false
  end

  def check_direction(row, col, player, row_delta, col_delta)
    count = 0
    5.times do
      row += row_delta
      col += col_delta
      break unless row.between?(0, @board_size - 1) && col.between?(0, @board_size - 1) && @game_board[row][col] == player
      count += 1
    end
    count
  end

  private

  def set_and_return_move(move)
    set_game_move([move[0], move[1], 1])
    "#{move[0]},#{move[1]}"
  end
end

class GameCommands
  def initialize(game_board)
    @game_board = game_board
  end

  def process_command(options)
    command = options[0].downcase.to_sym
    if respond_to?(command)
      send(command, options)
    else
      send_command("UNKNOWN")
    end
  end

  def send_command(cmd)
    puts cmd
    $stdout.flush
  end

  def start(options)
    size = options[1].to_i
    if size.positive?
      send_command("OK")
      @game_board.set_board_size(size)
      @game_board.reset_game_board
    else
      send_command("ERROR")
    end
  end

  def turn(options)
    if options.length == 2
      begin
        split = options[1].split(',')
        x = split[0].to_i
        y = split[1].to_i
        @game_board.set_game_move([x, y, 2])
        best_move = @game_board.get_best_move
        send_command(best_move)
      rescue
        send_command("ERROR")
      end
    else
      send_command("ERROR")
    end
  end

  def info(options)
    send_command("UNKNOWN")
  end

  def begin_command(options)
    @game_board.set_game_move([@game_board.get_board_size / 2, @game_board.get_board_size / 2, 1])
    send_command("#{@game_board.get_board_size / 2},#{@game_board.get_board_size / 2}")
  end
  
  def board(options)
    if options.length != 1
      send_command("ERROR")
      return
    end
    cmd = gets.strip
    split = cmd.split(',')
    if split.length != 3
      send_command("ERROR")
      return
    end
    while cmd != "DONE"
      if split.length != 3
        send_command("ERROR")
      end
      x = split[0].to_i
      y = split[1].to_i
      player = split[2].to_i
      @game_board.set_game_move([x, y, player])
      cmd = gets.strip
      split = cmd.split(',')
    end
    best_move = @game_board.get_best_move
    send_command(best_move)
  end

  def get_command(line)
    split = line.split(' ')
    if split.include?("START") || split.include?("RECSTART")
      start(split)
    elsif split.include?("TURN")
      turn(split)
    elsif split.include?("BEGIN")
      begin_command(split)
    elsif split.include?("BOARD")
      board(split)
    elsif split.include?("INFO")
      info(split)
    elsif split.include?("END")
      exit(0)
    elsif split.include?("ABOUT")
      send_command('1337 Vaincra.')
    else
      send_command("UNKNOWN")
    end
  end
end

if __FILE__ == $0
  game_board = GameBoard.new
  game_commands = GameCommands.new(game_board)

  loop do
    game_commands.get_command(gets.strip)
  end
end
