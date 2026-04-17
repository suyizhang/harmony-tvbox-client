import { BackendDetail, BackendPlayResponse, BackendSource } from '../model/ApiModels'
import { SourceUiModel } from '../model/Models'

export class BackendApiService {
  async fetchSources(baseUrl: string): Promise<BackendSource[]> {
    const response = await fetch(`${baseUrl}/sources`)
    return await response.json() as BackendSource[]
  }

  async fetchDetail(baseUrl: string, id: string): Promise<BackendDetail> {
    const response = await fetch(`${baseUrl}/detail?id=${encodeURIComponent(id)}`)
    return await response.json() as BackendDetail
  }

  async fetchPlay(baseUrl: string, id: string): Promise<BackendPlayResponse> {
    const response = await fetch(`${baseUrl}/play?id=${encodeURIComponent(id)}`)
    return await response.json() as BackendPlayResponse
  }

  mapBackendSources(items: BackendSource[]): SourceUiModel[] {
    return items.map(item => ({
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      supportsSearch: item.searchable,
      raw: {
        key: item.id,
        name: item.title,
        ext: ''
      }
    }))
  }
}
