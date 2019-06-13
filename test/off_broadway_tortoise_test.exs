defmodule OffBroadwayTortoiseTest do
  use OffBroadwayTortoise.Case, async: true

  @moduletag capture_log: true

  describe "unique_client_id_/1" do
    test "returns a string" do
      assert id = OffBroadwayTortoise.unique_client_id()
      assert is_binary(id)
      assert Regex.match?(~r/^off_broadway_tortoise_.+/, id)
    end

    test "returns unique client ids" do
      ids =
        for _ <- 1..100 do
          OffBroadwayTortoise.unique_client_id()
        end

      assert ids == Enum.uniq(ids)
    end

    test "takes the client_id_prefix from config" do
      assert id =
               OffBroadwayTortoise.unique_client_id(%{client_id_prefix: "asd"})

      assert Regex.match?(~r/^asd_.+/, id)
    end
  end

  describe "queue_name" do
    test "returns the process name for a topic queue server" do
      assert {:via, Registry, {:foo, "bar"}} ==
               OffBroadwayTortoise.queue_name(:foo, "bar")
    end

    test "returns the process name with the default registry" do
      assert {:via, Registry, {OffBroadwayTortoise.QueueRegistry, "bar"}} ==
               OffBroadwayTortoise.queue_name("bar")
    end
  end

  describe "config/1" do
    test "returns the mqtt config" do
      assert %{
               client_id_prefix: "off_broadway_tortoise",
               conn: {:tcp, [host: 'vernemq', port: 1883]}
             } == OffBroadwayTortoise.config()
    end

    test "sets transport" do
      assert %{
               conn: {:ssl, _}
             } = OffBroadwayTortoise.config(connection: [transport: :ssl])
    end

    test "parses port and host" do
      assert %{
               conn: {:tcp, [host: 'test', port: 1111]}
             } =
               OffBroadwayTortoise.config(
                 connection: [host: "test", port: "1111"]
               )
    end
  end
end
