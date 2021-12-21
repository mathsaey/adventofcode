import AOC

aoc 2021, 4 do
  def p1, do: {boards(), marked()} |> find(&first_winner/3) |> score()
  def p2, do: {boards(), marked()} |> find(&last_winner/3) |> score()

  def boards do
    input_string() |> String.split("\n\n") |> Enum.drop(1) |> Enum.map(&parse_board/1)
  end

  def marked do
    input_stream()
    |> Stream.take(1)
    |> Enum.to_list()
    |> hd()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def parse_board(string) do
    string |> String.split("\n") |> Enum.map(fn
      row -> row |>  String.split() |> Enum.map(&String.to_integer/1)
    end)
  end

  def board_to_rows_cols(board), do: board ++ transpose(board)
  def transpose(lst), do: lst |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

  def board_wins?({rows_cols, _}, nums) do
    Enum.any?(rows_cols, fn lst -> Enum.all?(lst, &(&1 in nums)) end)
  end

  def find_winning_board(boards, nums), do: Enum.find(boards, &board_wins?(&1, nums))

  def find({boards, nums}, search_fn) do
    boards = Enum.map(boards, &{board_to_rows_cols(&1), &1})
    {{_, board}, nums} = search_fn.(boards, [], nums)
    {board, nums}
  end

  def first_winner(boards, current_nums, [nums_hd | nums_tl]) do
    if board = find_winning_board(boards, current_nums) do
      {board, current_nums}
    else
      first_winner(boards, [nums_hd | current_nums], nums_tl)
    end
  end

  # Keep playing until last remaining board "won"
  def last_winner([board], current, remaining), do: first_winner([board], current, remaining)

  def last_winner(boards, current_nums, remaining = [nums_hd | nums_tl]) do
    if board = find_winning_board(boards, current_nums) do
      boards |> List.delete(board) |> last_winner(current_nums, remaining)
    else
      last_winner(boards, [nums_hd | current_nums], nums_tl)
    end
  end

  def score({board, marked = [final | _]}) do
    unmarked_sum = board |> List.flatten() |> Enum.reject(&(&1 in marked)) |> Enum.sum()
    unmarked_sum * final
  end
end
