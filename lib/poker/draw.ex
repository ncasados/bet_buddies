defmodule Poker.Draw do
  use Ecto.Schema

  embedded_schema do
    field :drawn_cards, {:array, :map}
    field :new_deck, {:array, :map}
  end
end
