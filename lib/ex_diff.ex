defmodule ExDiff do
  @moduledoc """
  Calculate diff over mixed nested data structures.
  """

  @type t :: %{
          (String.t()
           | atom()) => diff()
        }

  @type diff :: %{
          removed: [String.t() | atom()],
          added: [String.t() | atom()],
          changed: %{
            (String.t()
             | atom()) => %{
              old_value: String.t(),
              new_value: String.t()
            }
          }
        }

  @spec diff(String.t() | atom(), any, any) :: ExDiff.t()
  def diff(key \\ "root", stuff1, stuff2)

  def diff(key, {} = tuple_1, {} = tuple_2),
    do: diff(key, Tuple.to_list(tuple_1), Tuple.to_list(tuple_2))

  def diff(k, %{__struct__: _} = struct_1, %{__struct__: _} = struct_2),
    do: diff(k, Map.from_struct(struct_1), Map.from_struct(struct_2))

  def diff(key, %{} = map_1, %{} = map_2) do
    diff =
      Enum.concat(
        Map.keys(map_1),
        Map.keys(map_2)
      )
      |> Enum.uniq()
      |> Enum.reduce(
        %{},
        fn key, acc ->
          new_diff = diff(key, Map.get(map_1, key), Map.get(map_2, key))
          merge_diffs(acc, new_diff)
        end
      )

    if Enum.empty?(diff),
      do: %{},
      else: %{
        key => diff
      }
  end

  def diff(key, [_ | _] = list_1, [_ | _] = list_2) do
    indexes = 0..max(Enum.count(list_1), Enum.count(list_2))

    diff =
      Enum.reduce(
        indexes,
        %{},
        fn index, acc ->
          new_diff = diff("#{index}", Enum.at(list_1, index, nil), Enum.at(list_2, index, nil))
          merge_diffs(acc, new_diff)
        end
      )

    if Enum.empty?(diff),
      do: %{},
      else: %{
        key => diff
      }
  end

  def diff(_k, v1, v2) when v1 == v2, do: %{}
  def diff(k, _v1, nil), do: %{removed: [k]}
  def diff(k, nil, _v2), do: %{added: [k]}

  def diff(k, v1, v2) do
    s1 = Poison.encode!(v1)
    s2 = Poison.encode!(v2)

    %{
      changed: %{
        k => %{
          old_value: s1,
          new_value: s2
        }
      }
    }
  end

  defp merge_diffs(old_diff, new_diff) do
    Map.merge(
      old_diff,
      new_diff,
      fn
        _k, [_ | _] = v1, [_ | _] = v2 ->
          v1 ++ v2

        :changed, %{} = v1, %{} = v2 ->
          Map.merge(v1, v2)
      end
    )
  end
end
