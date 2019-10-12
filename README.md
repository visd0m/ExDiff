# ExDiff

**Get a simple diff of two nested mixed structures**

## Diff

Diff result types
```elixir
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
```

## Usage

Some usage examples:

- One level maps
    ```elixir
    ExDiff.diff(
          %{
            key_in_both: "old_value",
            removed_key: "only_in_map_1"
          },
          %{
            key_in_both: "new_value",
            added_key: "only_in_map_2"
          }
        )
  
    ## diff
  
    %{
        "root" => %{
             added: [:added_key],
             changed: %{
               key_in_both: %{
                 new_value: "\"new_value\"",
                 old_value: "\"old_value\""
               }
             },
             removed: [:removed_key]
        }
    }
    ```
- Nested maps
    ```elixir
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
                  added_key: "only_in_map_2"
                }
              }
            )
  
    ## dif 
  
    %{
         "root" => %{
           nested_map: %{
             added: [:added_key],
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
    ```
 - Lists
    ```elixir
    ExDiff.diff([1, 2, 3], [1, 3, 3, 4])
   
    ## diff
    
    %{
      "root" => %{
        added: ["3"],
        changed: %{"1" => %{new_value: "3", old_value: "2"}}
      }
    }
    ```
   
  - Tuples
    ```elixir
    
    ```
