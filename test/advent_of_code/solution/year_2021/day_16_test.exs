defmodule AdventOfCode.Solution.Year2021.Day16Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2021.Day16

  test "part1" do
    assert 6 == part1("D2FE28")
    assert 16 == part1("8A004A801A8002F478")
    assert 12 == part1("620080001611562C8802118E34")
    assert 23 == part1("C0015000016115A2E0802F182340")
    assert 31 == part1("A0016C880162017C3686B18A3D4780")
  end

  test "part2" do
    assert 3 == part2("C200B40A82")
    assert 54 == part2("04005AC33890")
    assert 7 == part2("880086C3E88112")
    assert 9 == part2("CE00C43D881120")
    assert 1 == part2("D8005AC2A8F0")
    assert 0 == part2("F600BC2D8F")
    assert 0 == part2("9C005AC2F8F0")
    assert 1 == part2("9C0141080250320F1802104A08")
  end
end
