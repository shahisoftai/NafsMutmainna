// API Client - Infrastructure layer for backend communication

import axios, { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { API_CONFIG } from '../../shared/constants';
import { useAppStore } from '../store';

// Create axios instance with default config
const createApiClient = (): AxiosInstance => {
    const client = axios.create({
        baseURL: API_CONFIG.baseUrl,
        timeout: API_CONFIG.timeout,
        headers: {
            'Content-Type': 'application/json',
            'X-App-Version': '1.0.0',
            'X-Platform': 'mobile',
        },
    });

    // Request interceptor - Add auth ID
    client.interceptors.request.use(
        (config: InternalAxiosRequestConfig) => {
            const anonymousId = useAppStore.getState().anonymousId;
            if (anonymousId) {
                config.headers.set('X-Anonymous-ID', anonymousId);
            }
            return config;
        },
        (error) => Promise.reject(error)
    );

    // Response interceptor - Handle errors
    client.interceptors.response.use(
        (response) => response,
        async (error: AxiosError) => {
            const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

            // Handle 401 - clear stale anonymous ID and retry once
            if (error.response?.status === 401 && !originalRequest._retry) {
                originalRequest._retry = true;
                useAppStore.getState().setAnonymousId(null as any);
                return client(originalRequest);
            }

            // Handle network errors
            if (!error.response) {
                console.error('Network error:', error.message);
            }

            return Promise.reject(error);
        }
    );

    return client;
};

export const apiClient = createApiClient();

// API Response types
export interface ApiResponse<T> {
    success: boolean;
    data: T;
    message?: string;
}

export interface ApiError {
    success: false;
    error: {
        code: string;
        message: string;
        details?: Record<string, string[]>;
    };
}

// Helper function for typed API calls
export async function apiGet<T>(
    endpoint: string,
    params?: Record<string, unknown>
): Promise<T> {
    const response = await apiClient.get<ApiResponse<T>>(endpoint, { params });
    return response.data.data;
}

export async function apiPost<T>(
    endpoint: string,
    data?: unknown
): Promise<T> {
    const response = await apiClient.post<ApiResponse<T>>(endpoint, data);
    return response.data.data;
}

export async function apiPut<T>(
    endpoint: string,
    data?: unknown
): Promise<T> {
    const response = await apiClient.put<ApiResponse<T>>(endpoint, data);
    return response.data.data;
}

export async function apiDelete<T>(
    endpoint: string
): Promise<T> {
    const response = await apiClient.delete<ApiResponse<T>>(endpoint);
    return response.data.data;
}