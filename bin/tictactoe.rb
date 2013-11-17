class TicTacToe
       
    #Read access to some class variables
    attr_reader :winner
    attr_reader :movenum
    attr_reader :player1
    attr_reader :player2
    attr_reader :cat
		attr_reader :currentturn
		attr_reader :difficulty
    
    def initialize
        #Set starting values for class variables
        #@board = ['_','_','_','_','_','_','_','_','_']
        @board = Array.new(9,'_')
        #Keep track of current player
        @currentturn = 'X'
        @winner = ''
        @movenum = 0
        @lastmoveindex = -1
        @penultimatemoveindex = -1
        @difficulty = 'easy'
        @movesuccess = false
        @alternate = true
    end
    
    def Reset
        #Reset game specific variables
        @board = Array.new(9,'_')
        @currentturn = 'X'
        @winner = ''
        @movenum = 0
        @lastmoveindex = -1
        @playagain = true
    end
    
    def PrintInstructions       
        if player1.mark == 'X' 
            return player1.name + ' (X) goes first'
        else
            return player2.name + ' (X) goes first'
        end
    end

    def SelectPlayers(numplayers)
        if @movenum == 0 or @winner != '' then
            if numplayers == 1
                @player1 = Player.new('human', 'Player','X')
                @player2 = Player.new('computer', 'Computer','O')
                @cat = Player.new('cat', 'Cat', 'C')
            elsif numplayers == 2
                @player1 = Player.new('human', 'Player 1','X')
                @player2 = Player.new('human', 'Player 2','O')
                @cat = Player.new('cat', 'Cat', 'C')
            else
                raise 'Invalid number of players: ' + numplayers
            end
        else
            raise "Cannot change players during game"
        end
    end
    
    def SwapPlayers
        @player1.SwapMark()
        @player2.SwapMark()
    end 
    
    def UpdateScore(winner)
        #Add a point to the winning player's score
        if @player1.mark == winner
            @player1.AddScore()
        elsif @player2.mark == winner
            @player2.AddScore()
        else
            @cat.AddScore()
        end
    end
    
    def ClearScore
        @player1.ClearScore
        @player2.ClearScore
        @cat.ClearScore
    end
  
		def SetDifficulty(difficulty)
			if @movenum == 0 or @winner != ''
				case difficulty.downcase
				when 'easy'
					@difficulty = 'easy'
				when 'normal'
					@difficulty = 'normal'
				when 'hard'
					@difficulty = 'hard'
				else
					raise 'Only valid difficulties are easy, medium, and hard'
				end
			end
		end
       
    #Print outcome of game to players
    def PrintWinner
        if @winner == 'C'
            return "Sorry, cat game."
        else
            if @player1.mark == @winner
                return "Congratulations! " + @player1.name + " wins!"
            elsif @player2.mark == @winner and @player2.type == 'human'
                return "Congratulations! " + @player2.name + " wins!"
            elsif @player2.mark == @winner and @player2.type == 'computer'
                #1 player, 'O' won. Do not congratulate player on computer victory.
                return "Sorry, " + player2.name + " wins."
            end
        end
    end
   
		def SwapTurn()
				#Toggle current player
				if @currentturn == 'X'
				    @currentturn = 'O'
				else
				    @currentturn = 'X'
				end
		end

		def SpaceAvailable(move)
				if @winner == ''
						return @board[move-1] == '_'
				else
						return false
				end
		end
    
    def MakeMove(move)
        #store up to 2 moves for undo
        @penultimatemoveindex = @lastmoveindex
        @lastmoveindex = move-1
        #Array index is one less than move space
        if @board[@lastmoveindex] == '_'
            @board[@lastmoveindex] = @currentturn

            #Increment move counter
            @movenum += 1
            @movesuccess = true
        else
            #Do not allow player to choose space that has already been played
            @movesuccess = false
        end
    end

		def ComputerMove()
			if @player2.type == 'computer' and @player2.mark == 'O'
				return ComputerMoveO()
			elsif @player2.type == 'computer' and @player2.mark == 'X'
				return ComputerMoveX()
			end
		end

		

		def GetLastMove()
			return @lastmoveindex
		end

		def GetPenultimateMove()
			return @penultimatemoveindex
		end
    
    def UndoMove()
        if @lastmoveindex == -1
            return "Move cannot be undone"
        else
            if @player2.type=='computer'
                #Undo computer and player move
                #Clear 2 moves from board
                @board[@lastmoveindex] = '_'
                @board[@penultimatemoveindex] = '_'
                @lastmoveindex = -1
                @penultimatemoveindex = -1
                @movenum -= 2
            else
                #Undo player move only
                #Clear move
                @board[@lastmoveindex] = '_'
                @lastmoveindex = -1
                #Decrement move counter
                @movenum -= 1
                
                #Toggle current player
                if @currentturn == 'X'
                    @currentturn = 'O'
                else
                    @currentturn = 'X'
                end
            end
            return "Move undone"
        end
    end

 def ShowComputerMove(move)
        #Need to increment index to match normal layout
        if @keyboard
            movestring = @keyboardboard[move]
        elsif @numpad
            movestring = @numpadboard[move]
        else
            movestring = (move+1).to_s
        end
        return "Computer chooses " + movestring
    end
    
    def CheckWinner(lastmove)
				lastmoveindex = lastmove - 1
        if @movenum < 3
            #Game cannot end in less than 5 moves
            #However, computer uses this to check for blocks on move 4
            return ''
        else
            row = lastmoveindex / 3
            #Determine row to check using integer division
            if (row == 0 and CheckWinTopRow()) or (row ==1 and CheckWinCenterRow()) or (row == 2 and CheckWinBottomRow())
								@winner = @currentturn
						end
            
            column = lastmoveindex % 3
            #Determine column to check
            if (column == 0 and CheckWinLeftColumn()) or (column == 1 and CheckWinMiddleColumn()) or (column == 2 and CheckWinRightColumn())
								@winner = @currentturn
						end
            
            if lastmoveindex % 2 == 0
                #Determine diagonals to check
                if lastmoveindex != 4 and lastmoveindex % 4 == 2
                    if CheckWinBottomLeftToTopRight() then @winner = @currentturn end
                elsif lastmoveindex != 4 and lastmoveindex %4 == 0
                    if CheckWinTopLeftToBottomRight() then @winner = @currentturn end
                elsif lastmoveindex == 4
                    if CheckWinTopLeftToBottomRight() 
											@winner = @currentturn   
                    elsif CheckWinBottomLeftToTopRight() 
											@winner = @currentturn 
										end
                end
            end
        end

        if @movenum == 9 and @winner == ''
            #Game over, no winner; cat's game
						@winner = 'C'
        end

				return @winner
    end


private

		def ComputerMoveX()
			if @difficulty == 'easy'
        #Easy computer moves randomly
        move = RandomMove()
			elsif @difficulty == 'normal'
				#Normal computer moves randomly early on, but looks for wins or blocks as the game progresses
				if @movenum < 3
				    move = RandomMove()
				else
				    #Check for winning move first
				    move = FindWinningMove()
				    if move == -1
					 		#No winning move available, try block next
							move = FindBlockingMove()
							if move == -1 then
					    	move = RandomMove()
							end
				    end
				end
			elsif @difficulty == 'hard'
				#Hard computer knows what move to make in every situation, until cat game is guaranteed
				case movenum 
				when 0
					move = 0
				when 2
					case @lastmoveindex
					when 1,3,5,7
						move = 4
					when 2,4,6
						move = 8
					else
						move = 2
					end
				when 4
					move = FindWinningMove()
					if move == -1
						move = FindBlockingMove()
						if move == -1
							move = 6
						end
					end
				else
					move = FindWinningMove()
					if move == -1
						move = FindBlockingMove()
						if move == -1
							move = RandomMove()
						end
					end
				end
				return move + 1
			end
		end
   
    def ComputerMoveO()
        if @winner == ''
            if @difficulty == 'easy'
                #Easy computer moves randomly
                move = RandomMove()
            elsif @difficulty == 'normal'
                #Normal computer moves randomly early on, but looks for wins or blocks as the game progresses
                if @movenum < 3
                    move = RandomMove()
                else
                    #Check for winning move first
                    move = FindWinningMove()
                    if move == -1
                         #No winning move available, try block next
                        move = FindBlockingMove()
                        if move == -1 then
                            move = RandomMove()
                        end
                    end
                end
            elsif @difficulty == 'hard'
                #Hard computer knows what move to make in every situation, until cat game is guaranteed
                move = -1
                if @movenum == 1
                    if @board[4] == '_'
                        move = 4
                    else
                        move = 0
                    end
                elsif @movenum == 3
                    if @board[4] == 'X'
                        if @board[0] != '_' and @board[8] != '_'
                            move = 2
                        elsif @board[2] != '_' and @board[6] != '_'
                            move = 0
                        end
                    else
                        if (@board[1] == 'X' and @board[5] == 'X') or (@board[3] == 'X' and @board[7] == 'X')
                            move = 0
                        elsif (@board[3] == 'X' and @board[8] == 'X') or (@board[5] == 'X' and @board[6] == 'X') or (@board[3] == 'X' and @board[5] == 'X') or (@board[0] == 'X' and @board[8] == 'X') or (@board[2] == 'X' and @board[6] == 'X')
                            move = 1
                        elsif (@board[1] == 'X' and @board[3] == 'X') or (@board[5] == 'X' and @board[7] == 'X')
                            move = 2
                        elsif (@board[2] == 'X' and @board[7] == 'X') or (@board[1] == 'X' and @board[8] == 'X') or (@board[1] == 'X' and @board[7] == 'X')
                            move = 3
                        elsif (@board[1] == 'X' and @board[6] == 'X') or (@board[0] == 'X' and @board[7] == 'X')
                            move = 5
                        elsif (@board[0] == 'X' and @board[5] == 'X') or (@board[2] == 'X' and @board[3] == 'X')
                            move = 7
                        end
                    end
                elsif @movenum == 5
                    if (@board[4] == 'O' and @board[5] == 'X' and @board[7] == 'X' and @board[1] != '_' and @board[3] != '_')
                        move = 0
                    end
                end
                if move == -1
                    #Check for winning move first
                    move = FindWinningMove()
                    if move == -1
                         #No winning move available, try block next
                        move = FindBlockingMove()
                        if move == -1 then
                            #puts "Select side"
                            if @board[1] == '_'
                                move = 1
                            elsif @board[3] == '_'
                                move = 3
                            elsif @board[5] == '_'
                                move = 5
                            elsif @board[7] == '_'
                                move = 7
                            end
                        end
                    end
                end
                

            end
						return (move+1)
        end
    end
    
    def FindWinningMove()
        #Pretend O went in any available square and check for win
        for i in 0..8
            if @board[i] == '_'
                @board[i] = @player2.mark
                if CheckWinner(i+1) == @player2.mark
                    @board[i] = '_'
										@winner = ''
                    return i
                end
                @board[i] = '_'
            end
        end
        return -1
    end
    
    def FindBlockingMove()
        #Pretend X went in any available square and check for win; that space necessitates a block
        for i in 0..8
            if @board[i] == '_'
                @board[i] = @player1.mark
                #CheckWinner returns currentturn, so it will still be O
                if CheckWinner(i+1) == @player2.mark
                    @board[i] = '_'
										@winner = ''
                    return i
                end
                @board[i] = '_'
            end
        end
        return -1
    end
    
    def RandomMove()
        #Select random number 0-8 inclusive; this will match board index
        move = rand(9)
        while @board[move] != '_'
            move = rand(9)
        end
        return move
    end
    
   
    
    def CheckWinLeftColumn()
		#[0 _ _]
		#[3 _ _]
		#[6 _ _]
        return ((@board[0] == @board[3]) and (@board[0] == @board[6]))
    end
    

    def CheckWinMiddleColumn()
		#[_ 1 _]
		#[_ 4 _]
		#[_ 7 _]
        return ((@board[4] == @board[1]) and (@board[4] == @board[7]))
    end
    
    def CheckWinRightColumn()
		#[_ _ 2]
		#[_ _ 5]
		#[_ _ 8]
        return ((@board[8] == @board[2]) and (@board[8] == @board[5]))
    end
    
    def CheckWinTopRow()
		#[0 1 2]
		#[_ _ _]
		#[_ _ _]
        return ((@board[0] == @board[1]) and (@board[0] == @board[2]))
    end
    
    def CheckWinCenterRow()
		#[_ _ _]
		#[3 4 5]
		#[_ _ _]
        return ((@board[4] == @board[3]) and (@board[4] == @board[5]))
    end
    
    def CheckWinBottomRow()
		#[_ _ _]
		#[_ _ _]
		#[6 7 8]
        return ((@board[8] == @board[7]) and (@board[8] == @board[6]))
    end
    
    def CheckWinTopLeftToBottomRight()
		#[0 _ _]
		#[_ 4 _]
		#[_ _ 8]
        return ((@board[4] == @board[0]) and (@board[4] == @board[8]))
    end
    
    def CheckWinBottomLeftToTopRight()
		#[_ _ 2]
		#[_ 4 _]
		#[6 _ _]
        return ((@board[4] == @board[2]) and (@board[4] == @board[6]))
    end
end
