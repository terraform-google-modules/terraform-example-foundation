resource "google_folder" "nonprod" {
    parent = local.parent_id
    display_name = "nonprod"
}

resource "google_folder" "prod" {
    parent = local.parent_id
    display_name = "prod"
}