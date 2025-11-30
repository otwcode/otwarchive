module QrCodeHelper
  def qr_code_as_svg(uri, aria_label: t("qr_code_helper.qr_code_as_svg.default_label"))
    RQRCode::QRCode.new(uri).as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 2,
      standalone: true,
      use_path: true,
      svg_attributes: { "aria-label": aria_label }
    ).html_safe
  end
end
