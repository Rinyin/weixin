import axios, { AbortController, AxiosError, AxiosHeaders, AxiosInstance, AxiosRequestConfig,
  AxiosResponse } from '@ohos/axios';
import { ApiResult, LoginRequest, OnlineProfile } from '../model/AuthModels';

// 本机 word-api；模拟器通过 HDC 反向转发连接，契约见 docs/AUTH_API.md。
export const AUTH_BASE_URL: string = 'http://127.0.0.1:3000';

export class AuthFailure extends Error {
  constructor(message: string) { super(message); }
}

export class AuthService {
  private static client: AxiosInstance = axios.create({
    baseURL: AUTH_BASE_URL,
    timeout: 10000,
    connectTimeout: 10000,
    responseType: 'object'
  });

  static validPhone(phone: string): boolean { return /^1\d{10}$/.test(phone.trim()); }
  static validCode(code: string): boolean { return /^\d{4,8}$/.test(code.trim()); }

  private static businessMessage(code: number): string {
    switch (code) {
      case 201: return '登录状态已失效，请重新登录';
      case 202: return '请填写验证码';
      case 203: return '验证码已过期，请重新获取';
      case 204: return '验证码错误，请检查后重试';
      case 205: return '请填写手机号';
      default: return '课程服务暂时无法处理此请求，请稍后重试';
    }
  }

  private static async request<T>(config: AxiosRequestConfig<LoginRequest>): Promise<T> {
    let response: AxiosResponse<ApiResult<T>, LoginRequest>;
    try {
      response = await AuthService.client.request<ApiResult<T>, AxiosResponse<ApiResult<T>, LoginRequest>, LoginRequest>(config);
    } catch (error) {
      // 不打印 Axios 错误对象：其中可能包含手机号、验证码及 token。
      if (axios.isCancel(error)) { throw new AuthFailure('请求已取消'); }
      if (axios.isAxiosError<string, LoginRequest>(error)) {
        const failure: AxiosError<string, LoginRequest> = error as AxiosError<string, LoginRequest>;
        const code = String(failure.code || '');
        if (code === '2300028' || code === 'ETIMEDOUT' || code === 'ECONNABORTED') {
          throw new AuthFailure('连接课程服务超时，请稍后重试');
        }
        // 鸿蒙适配层的网络错误也可能带 response，必须确认它是 HTTP 状态。
        if (failure.response && typeof failure.response.status === 'number' &&
          failure.response.status >= 100 && failure.response.status <= 599) {
          throw new AuthFailure('课程服务响应异常，请稍后重试');
        }
      }
      throw new AuthFailure('无法连接课程服务，请检查服务和网络后重试，或选择本地体验');
    }
    const result = response.data;
    if (!result || typeof result.code !== 'number') {
      throw new AuthFailure('课程服务返回的数据格式不正确');
    }
    if (result.code !== 200) { throw new AuthFailure(AuthService.businessMessage(result.code)); }
    if (result.data === undefined || result.data === null) {
      throw new AuthFailure('课程服务未返回所需数据');
    }
    return result.data;
  }

  static async requestCode(phone: string, controller: AbortController): Promise<string> {
    const value = phone.trim();
    if (!AuthService.validPhone(value)) { throw new AuthFailure('手机号应为 1 开头的 11 位数字'); }
    const code = await AuthService.request<string>({
      url: '/word/user/code?phone=' + encodeURIComponent(value), method: 'GET', signal: controller.signal
    });
    if (typeof code !== 'string' || !AuthService.validCode(code)) {
      throw new AuthFailure('课程服务返回的验证码格式不正确');
    }
    return code;
  }

  static async signIn(phone: string, code: string, controller: AbortController): Promise<OnlineProfile> {
    const form: LoginRequest = { phone: phone.trim(), code: code.trim() };
    if (!AuthService.validPhone(form.phone)) { throw new AuthFailure('手机号应为 1 开头的 11 位数字'); }
    if (!AuthService.validCode(form.code)) { throw new AuthFailure('验证码应为 4–8 位数字'); }
    const loginHeaders = new AxiosHeaders();
    loginHeaders.set('Content-Type', 'application/json');
    const token = await AuthService.request<string>({
      url: '/word/user/login', method: 'POST', headers: loginHeaders, data: form, signal: controller.signal
    });
    if (typeof token !== 'string' || !token.trim()) {
      throw new AuthFailure('课程服务未返回有效的登录凭据');
    }
    // token 只用于本次 info 请求，不写磁盘或 AppStorage，不加入默认请求头。
    const infoHeaders = new AxiosHeaders();
    infoHeaders.set('token', token);
    const profile = await AuthService.request<OnlineProfile>({
      url: '/word/user/info', method: 'GET', headers: infoHeaders, signal: controller.signal
    });
    if (!profile || typeof profile.nickname !== 'string' || typeof profile.avatarUrl !== 'string') {
      throw new AuthFailure('联机资料格式不正确，请重新登录');
    }
    return { nickname: profile.nickname.trim().slice(0, 80), avatarUrl: profile.avatarUrl.trim() };
  }
}
