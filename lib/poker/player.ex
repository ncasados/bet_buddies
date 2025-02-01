defmodule Poker.Player do
  alias Poker.HandLog
  alias Poker.Player
  use Ecto.Schema

  @type t :: %Player{
          player_id: String.t(),
          name: String.t(),
          wallet: integer(),
          contributed: integer(),
          hand: list(map()),
          is_host?: boolean(),
          last_action: HandLog.t(),
          last_actions: [HandLog.t()],
          is_all_in?: boolean(),
          is_big_blind?: boolean(),
          is_small_blind?: boolean(),
          is_under_the_gun?: boolean(),
          turn_number: integer(),
          folded?: boolean(),
          funny_collateral: String.t(),
          minimum_call: integer()
        }

  embedded_schema do
    field :player_id, :string
    field :name, :string
    field :wallet, :integer, default: 20_000
    field :contributed, :integer, default: 0
    field :hand, {:array, :map}, default: []
    field :is_host?, :boolean, default: false
    embeds_one :last_action, HandLog
    embeds_many :last_actions, HandLog
    field :is_all_in?, :boolean, default: false
    field :is_big_blind?, :boolean, default: false
    field :is_small_blind?, :boolean, default: false
    field :is_under_the_gun?, :boolean, default: false
    field :turn_number, :integer, default: 0
    field :folded?, :boolean, default: false
    field :funny_collateral, :string
    field :minimum_call, :integer, default: 0
  end

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
