resource "aws_guardduty_invite_accepter" "member_accepter" {
  count             = var.is_guardduty_member && length(var.master_account_id) > 0 ? 1 : 0
  detector_id       = aws_guardduty_detector.detector.id
  master_account_id = var.master_account_id
}
