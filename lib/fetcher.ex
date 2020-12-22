defmodule HarFetcher do

  def main(args \\ []),
    do: run(args)

  def run([]),
    do: IO.puts "You need to pass some .har file to parse."

  def run([argument | arguments]) do
    File.read(argument)
    |> case do
      {:ok, content} ->
        Jason.decode!(content)
        |> case do
          %{"log" => %{ "entries" => entries}} ->
            process_entries(entries)
          _ ->
            IO.puts "error"
        end
      _ ->
        IO.puts "error"
    end
    if arguments != [], do: run(arguments)
  end

  def process_entries(entries),
    do: process_entries(entries, [])

  def process_entries([], acc),
    do: acc

  def process_entries([entry | entries], acc) do
    process_entries(entries, [process_entry(entry) | acc])
  end

  def process_entry(%{"request"=> %{"url" => url}, "response" => %{"content" => content}}) do
    process_entry_values(url, content)
  end
  def process_entry(entry) do
    entry
  end

  def process_entry_values("http://"<>url, content),
  do: process_entry_values(url, content)

  def process_entry_values("https://"<>url, content),
  do: process_entry_values(url, content)

  def process_entry_values("/"<>url, content),
  do: process_entry_values(url, content)

  def process_entry_values(url, content) do
    {path, filename} = compute_path(url)
    content = compute_content(content)
    store_file(path, filename, content)
  end

  def compute_path(url) do
    path = Path.dirname(url)
    filename = String.replace(url, path<>"/", "")
#               |> String.split("?")
#               |> List.first()
    case filename do
      "" ->
        {path, "index.html"}
      _ ->
        {path, filename}
    end
  end

  def compute_content(%{"encoding" => "base64", "text" => data}),
  do: Base.decode64!(data)

  def compute_content(%{"text" => data}),
  do: data

  def compute_content(%{}),
  do: nil

  def store_file(path, filename, content) do
    with :ok <- File.mkdir_p(path) do
      File.write(path<>"/"<>filename, content)
    end
  end
end
