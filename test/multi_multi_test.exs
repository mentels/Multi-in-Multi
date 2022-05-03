defmodule MultiMultiTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "returns error about rolling back operation when inner fails" do
    assert_raise RuntimeError,
                 "operation :rollback is manually rolling back, which is not supported by Ecto.Multi",
                 fn ->
                   MultiMulti.run_in_multi(
                     subsystem_a: [fail_tx?: true],
                     subsystem_a_return: :ignore
                   )
                 end
  end

  test "returns connection error if we try to do recovery in a failed step" do
    assert_raise DBConnection.ConnectionError,
                 "transaction rolling back",
                 fn ->
                   MultiMulti.run_in_multi(
                     subsystem_a: [fail_tx?: true],
                     subsystem_a_return: :recover
                   )
                 end
  end

  test "complains about bad ecto callback if the error from inner Multi passes through" do
    assert_raise RuntimeError,
                 "expected Ecto.Multi callback named `:subsystem_a` to return either {:ok, value} or {:error, value}, got: {:error, :step, :reason, %{}}",
                 fn ->
                   MultiMulti.run_in_multi(subsystem_a: [fail_tx?: true])
                 end
  end

  test "doesn't execute the next step if the first fails" do
    log =
      capture_log(fn ->
        assert {:error, :subsystem_a, :proper_error, %{}} =
                 MultiMulti.run_in_multi(
                   subsystem_a: [fail_tx?: true],
                   subsystem_a_return: :error
                 )
      end)

    assert log =~ "Subsystem A failed"
    refute log =~ "Subsystem B failed"
  end
end
