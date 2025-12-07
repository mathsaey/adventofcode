import AOC

aoc_test 2025, 2, async: true do
  describe "part 1" do
    test "example input" do
      assert p1(example_string(0)) == 1227775554
    end

    test "personal input" do
      assert p1(input_string()) == 12586854255
    end
  end

  describe "part 2" do
    test "example input" do
      assert p2(example_string(0)) == 4174379265
    end

    test "personal input" do
      assert p2(input_string()) == 17298174201
    end
  end
end
