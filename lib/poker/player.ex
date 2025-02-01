defmodule Poker.Player do
  @moduledoc """
  Represents a poker player.
  """

  alias Poker.HandLog
  alias Poker.Player
  use Ecto.Schema

  @type t :: %Player{
          contributed: integer(),
          folded?: boolean(),
          funny_collateral: String.t() | nil,
          hand: list(map()),
          is_all_in?: boolean(),
          is_big_blind?: boolean(),
          is_host?: boolean(),
          is_small_blind?: boolean(),
          is_under_the_gun?: boolean(),
          last_action: HandLog.t() | nil,
          last_actions: [HandLog.t()],
          minimum_call: integer(),
          name: String.t(),
          player_id: String.t(),
          turn_number: integer(),
          wallet: integer()
        }

  defstruct contributed: 0,
            folded?: false,
            funny_collateral: "the house",
            hand: [],
            is_all_in?: false,
            is_big_blind?: false,
            is_host?: false,
            is_small_blind?: false,
            is_under_the_gun?: false,
            last_action: nil,
            last_actions: [],
            minimum_call: 0,
            name: "some-name",
            player_id: "some-uuid",
            turn_number: 1,
            wallet: 20_000

  # Queries

  def get_wallet(%Player{} = player) do
    Map.get(player, :wallet)
  end

  # Rules

  @spec has_enough_money?(Player.t(), integer()) :: boolean()
  def has_enough_money?(%Player{wallet: wallet}, amount_to_spend) do
    wallet > amount_to_spend
  end

  # Transformations

  @spec add_to_wallet(Player.t(), integer()) :: Player.t()
  def add_to_wallet(%Player{} = player, amount) do
    Map.update!(player, :wallet, fn wallet -> wallet + amount end)
  end

  def set_small_blind(%Player{} = player, bool) do
    Map.update!(player, :is_small_blind?, fn _ -> bool end)
  end

  def set_big_blind(%Player{} = player, bool) do
    Map.update!(player, :is_big_blind?, fn _ -> bool end)
  end

  def all_in(%Player{} = player) do
    player
    |> Map.update!(:wallet, fn _wallet -> 0 end)
    |> Map.update!(:contributed, fn contributed -> player.wallet + contributed end)
  end

  def set_minimum_call(%Player{} = player, amount) do
    Map.get(player, :minimum_call, amount)
  end

  @spec set_host(Player.t()) :: Player.t()
  def set_host(%Player{} = player) do
    Map.update!(player, :is_host?, fn _ -> true end)
  end

  @spec add_to_bet(Player.t(), integer()) :: Player.t()
  def add_to_bet(%Player{} = player, amount_to_add) do
    Map.update!(player, :contributed, fn contributed -> contributed + amount_to_add end)
  end

  @spec deduct_from_wallet(Player.t(), integer()) :: Player.t()
  def deduct_from_wallet(%Player{} = player, amount_to_deduct) do
    Map.update!(player, :wallet, fn wallet -> wallet - amount_to_deduct end)
  end

  @spec set_folded(Player.t(), boolean()) :: Player.t()
  def set_folded(%Player{} = player, status) do
    Map.update!(player, :folded?, fn _ -> status end)
  end
end
