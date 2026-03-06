resource "aws_customer_gateway" "cgw" {

  for_each = local.vpn_connections

  bgp_asn    = var.cgw_bgp_asn
  ip_address = each.value.ip
  type       = "ipsec.1"

  tags = merge(
    var.tags,
    {
      Name = "${var.domain}-cgw-${each.key}"
    }
  )
}

resource "aws_vpn_connection" "vpn" {

  for_each = aws_customer_gateway.cgw

  customer_gateway_id = each.value.id
  transit_gateway_id  = var.tgw_id
  type                = "ipsec.1"

  static_routes_only = false

  tags = merge(
    var.tags,
    {
      Name = "${var.domain}-vpn-${each.key}"
    }
  )
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_assoc" {

  for_each = aws_vpn_connection.vpn

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_rtb_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_prop" {

  for_each = aws_vpn_connection.vpn

  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_rtb_id
}