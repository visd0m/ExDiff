defmodule ExDiffTest do
  use ExUnit.Case
  doctest ExDiff

  defmodule TestStruct do
    defstruct [:a, :b, :c, :d, :e]
  end

  describe "primitive values" do
    test "diff on primitive values" do
      diff = ExDiff.diff(5, 6)

      assert diff == %{
               changed: %{
                 "root" => %{
                   new_value: "6",
                   old_value: "5"
                 }
               }
             }
    end

    test "no diff on primitive values" do
      diff = ExDiff.diff(6, 6)

      assert diff == %{}
    end
  end

  describe "maps" do
    test "diff on one level maps" do
      diff =
        ExDiff.diff(
          %{
            key_in_both: "old_value",
            removed_key: "only_in_map_1"
          },
          %{
            key_in_both: "new_value",
            added_lkey: "only_in_map_2"
          }
        )

      assert diff == %{
               "root" => %{
                 added: [:added_lkey],
                 changed: %{
                   key_in_both: %{
                     new_value: "\"new_value\"",
                     old_value: "\"old_value\""
                   }
                 },
                 removed: [:removed_key]
               }
             }
    end

    test "no diff on one level maps" do
      diff = ExDiff.diff(%{a: "a", b: "b", c: "c"}, %{a: "a", b: "b", c: "c"})

      assert diff == %{}
    end

    test "diff on nested maps" do
      diff =
        ExDiff.diff(
          %{
            nested_map: %{
              key_in_both: "old_value",
              removed_key: "only_in_map_1"
            }
          },
          %{
            nested_map: %{
              key_in_both: "new_value",
              added_lkey: "only_in_map_2"
            }
          }
        )

      assert diff == %{
               "root" => %{
                 nested_map: %{
                   added: [:added_lkey],
                   changed: %{
                     key_in_both: %{
                       new_value: "\"new_value\"",
                       old_value: "\"old_value\""
                     }
                   },
                   removed: [:removed_key]
                 }
               }
             }
    end

    test "no diff on nested maps" do
      diff =
        ExDiff.diff(
          %{
            nested_map: %{
              key_in_both: "old_value",
              removed_key: "only_in_map_1"
            }
          },
          %{
            nested_map: %{
              key_in_both: "old_value",
              removed_key: "only_in_map_1"
            }
          }
        )

      assert diff == %{}
    end
  end

  describe "structs" do
    test "diff on structs" do
      struct_1 = %TestStruct{
        a: "a",
        b: "b",
        c: "c",
        d: nil,
        e: "e"
      }

      struct_2 = %TestStruct{
        a: "b",
        b: "b",
        c: "a",
        d: "d",
        e: nil
      }

      diff = ExDiff.diff(struct_1, struct_2)

      assert diff == %{
               "root" => %{
                 added: [:d],
                 changed: %{
                   a: %{
                     new_value: "\"b\"",
                     old_value: "\"a\""
                   },
                   c: %{
                     new_value: "\"a\"",
                     old_value: "\"c\""
                   }
                 },
                 removed: [:e]
               }
             }
    end

    test "no diff on structs" do
      struct_1 = %TestStruct{
        a: "a",
        b: "b",
        c: "c",
        d: "d",
        e: "e"
      }

      struct_2 = %TestStruct{
        a: "a",
        b: "b",
        c: "c",
        d: "d",
        e: "e"
      }

      diff = ExDiff.diff(struct_1, struct_2)

      assert diff = %{}
    end
  end

  describe "different data structures" do
    test "primitive and map" do
      diff = ExDiff.diff(2, %{a: "a"})

      assert diff = %{
               changed: %{
                 "root" => %{
                   new_value: "{\"a\":\"a\"}",
                   old_value: "2"
                 }
               }
             }
    end
  end
end
