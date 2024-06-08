defmodule Tux.ConfigTest do
  use ExUnit.Case

  alias Tux.Config
  alias Tux.Errors

  setup_all do
    """
    # Some key with value
    key = value

    # Blanks will be nil
    name =

    # No space between key-value pair works too
    abc=def

    ; windows style comments also work
    ; and any [sections] will be ignored
    [section]
    num=10
    """
    |> (fn contents -> File.write!("test.config", contents) end).()

    on_exit(fn -> File.rm!("test.config") end)
    {:ok, %{filename: "test.config"}}
  end

  describe "read" do
    test "a good file" do
      filename = "good-file.config"
      File.write!(filename, "key=value")
      data = Config.read_file!(filename)
      assert data == %{"key" => "value"}
      File.rm!(filename)
    end

    test "a malformed file file" do
      filename = "bad-file.config"
      File.write!(filename, "key=value")
      File.chmod!(filename, 0o000)
      assert {:error, :eacces} == Config.read_file(filename)
      File.rm!(filename)
    end
  end

  describe "config" do
    test "not found" do
      {:error, :file_not_found} = Config.read_file("bla")
    end

    test "read & read!", %{filename: filename} do
      {:ok, data} = Config.read_file(filename)
      assert data == %{"key" => "value", "name" => nil, "abc" => "def", "num" => "10"}

      # Keys as atoms
      data = Config.read_file!(filename, keys: :atoms)
      assert data == %{key: "value", name: nil, abc: "def", num: "10"}

      # Keys as atoms!
      data = Config.read_file!(filename, keys: :atoms!)
      assert data == %{key: "value", name: nil, abc: "def", num: "10"}
    end

    test "read!" do
      assert_raise(Errors.ConfigReadError, fn ->
        Config.read_file!("some-bad-file")
      end)
    end

    test "write" do
      filename = "written.config"

      # Write
      updated = %{key: "v1", name: "n1"}
      :ok = Config.write_file(filename, updated)
      :ok = Config.write_file!(filename, updated)

      # Verify
      {:ok, read} = Config.read_file(filename, keys: :atoms)
      assert read == %{key: "v1", name: "n1"}

      File.rm!(filename)
    end

    test "write!" do
      assert_raise(Errors.ConfigWriteError, fn ->
        config = %{key: "value"}
        Config.write_file!("/tmp/some/bad/path/file.config", config)
      end)
    end
  end
end
