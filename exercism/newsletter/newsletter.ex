defmodule Newsletter do
  def read_emails(path) do
    path
    |> File.read!()
    |> String.split()
  end

  def open_log(path), do: File.open!(path, [:write])

  def log_sent_email(pid, email), do: IO.puts(pid, email)

  def close_log(pid), do: File.close(pid)

  def send_newsletter(emails_path, log_path, send_fun) do
    log = open_log(log_path)

    Enum.each(read_emails(emails_path), fn email ->
      case send_fun.(email) do
        :ok -> log_sent_email(log, email)
        error -> error
      end
    end)

    close_log(log)
  end
end
