export interface BackendSource {
  id: string
  title: string
  subtitle: string
  searchable: boolean
}

export interface BackendDetail {
  id: string
  title: string
  description: string
  playUrl?: string
}

export interface BackendPlayResponse {
  id: string
  url: string
  type: string
}
