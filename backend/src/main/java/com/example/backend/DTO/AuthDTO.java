package com.example.backend.DTO;

import lombok.Data;

public class AuthDTO {

    // DTO cho đăng nhập
    @Data
    public static class LoginRequest {
        private String email;
        private String password;
    }

    // DTO cho xác thực email
    @Data
    public static class VerificationRequest {
        private String email;
        private String verificationCode;
    }

    // DTO cho đăng ký
    @Data
    public static class RegistrationRequest {
        private String fullName;
        private String email;
        private String password;
    }
}