import AOC

aoc_test 2025, 1, async: true do
  describe "part 1" do
    test "example input" do
      assert p1(example_string(0)) == 3
    end

    test "personal input" do
      assert p1(input_string()) == 1123
    end
  end

  describe "part 2" do
    test "example input" do
      assert p2(example_string(0)) == 6
    end

    test "personal input" do
      assert p2(input_string()) == 6695
    end
  end
end
