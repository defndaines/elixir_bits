defmodule PaintByNumber do
  @empty <<>>

  def palette_bit_size(color_count), do: (color_count - 1) |> Integer.digits(2) |> length()

  def empty_picture(), do: @empty

  def test_picture(), do: <<0::2, 1::2, 2::2, 3::2>>

  def prepend_pixel(picture, color_count, pixel_color_index) do
    bits = palette_bit_size(color_count)
    <<pixel_color_index::size(bits), picture::bitstring>>
  end

  def get_first_pixel(@empty, _), do: nil

  def get_first_pixel(picture, color_count) do
    bits = palette_bit_size(color_count)
    <<head::size(bits), _::bitstring>> = picture
    head
  end

  def drop_first_pixel(@empty, _), do: @empty

  def drop_first_pixel(picture, color_count) do
    bits = palette_bit_size(color_count)
    <<_::size(bits), rest::bitstring>> = picture
    rest
  end

  def concat_pictures(picture1, picture2), do: <<picture1::bitstring, picture2::bitstring>>
end
