defmodule KV.Registry.Server do
  use GenServer

  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  def handle_call({:names, :all}, _from, state) do
    {names, _} = state
    {:reply, names, state}
  end

  def handle_call({:refs, :all}, _from, state) do
    {_, refs} = state
    {:reply, refs, state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref_monitor = Process.monitor(bucket)
      new_refs = Map.put(refs, ref_monitor, name)
      new_names = Map.put(names, name, bucket)
      new_state = {new_names, new_refs}
      {:noreply, new_state}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
