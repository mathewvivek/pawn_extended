require_relative 'pawn_simulator'

simulator = PawnSimulator.new
puts "# Enter your command:"
puts "# \' Pawn|Rook place X,Y, North|South|East|West, White|Black \', Move, Left, Right, Report or Exit"

command = STDIN.gets

while command
  command.strip!
  if command.downcase == "exit"
    puts "# Bye"
    exit
  else
    output = simulator.process(command)
    puts output if output
    command = STDIN.gets
  end
end