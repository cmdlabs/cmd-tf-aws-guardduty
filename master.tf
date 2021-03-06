resource "aws_s3_bucket" "bucket" {
  count  = var.is_guardduty_master && (length(var.ipset_iplist) > 0 || length(var.threatintelset_iplist) > 0) ? 1 : 0
  bucket = var.bucket_name
  versioning {
    enabled = true
  }
  policy        = data.aws_iam_policy_document.s3_policy.json
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_object" "ipset" {
  count = var.is_guardduty_master && length(var.ipset_iplist) > 0 ? 1 : 0
  acl   = "public-read"
  content = templatefile("${path.module}/templates/ipset.txt.tpl",
  { ipset_iplist = var.ipset_iplist })
  bucket = aws_s3_bucket.bucket[0].id
  key    = local.ipset_key
}

resource "aws_guardduty_ipset" "ipset" {
  count       = var.is_guardduty_master && length(var.ipset_iplist) > 0 ? 1 : 0
  activate    = true
  detector_id = aws_guardduty_detector.detector.id
  format      = var.ipset_format
  location    = "https://s3.amazonaws.com/${aws_s3_bucket.bucket[0].id}/${local.ipset_key}"
  name        = local.ipset_name
}

resource "aws_s3_bucket_object" "threatintelset" {
  count = var.is_guardduty_master && length(var.threatintelset_iplist) > 0 ? 1 : 0
  acl   = "public-read"
  content = templatefile("${path.module}/templates/threatintelset.txt.tpl",
  { threatintelset_iplist = var.threatintelset_iplist })
  bucket = aws_s3_bucket.bucket[0].id
  key    = local.threatintelset_key
}

resource "aws_guardduty_threatintelset" "threatintelset" {
  count       = var.is_guardduty_master && length(var.threatintelset_iplist) > 0 ? 1 : 0
  activate    = true
  detector_id = aws_guardduty_detector.detector.id
  format      = var.threatintelset_format
  location    = "https://s3.amazonaws.com/${aws_s3_bucket.bucket[0].id}/${local.threatintelset_key}"
  name        = local.threatintelset_name
}

resource "aws_guardduty_member" "members" {
  count              = var.is_guardduty_master ? length(var.member_list) : 0
  account_id         = var.member_list[count.index]["account_id"]
  detector_id        = aws_guardduty_detector.detector.id
  email              = var.member_list[count.index]["member_email"]
  invite             = var.member_list[count.index]["invite"]
  invitation_message = "Please accept GuardDuty invitation"
}
