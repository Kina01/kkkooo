package com.example.backend.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.example.backend.Repository.UserRepository;

import java.security.SecureRandom;

@Service
public class EmailVerificationService {

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private CacheManager cacheManager;

    @Autowired
    private UserRepository userRepository;

    private static final String CACHE_NAME = "verificationCodes";
    private static final String VERIFIED_EMAILS_CACHE = "verifiedEmails";
    private static final long CODE_EXPIRATION_MINUTES = 10;

    private final SecureRandom secureRandom = new SecureRandom();

    public String generateAndSendVerificationCode(String email) {
        if (userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email đã được đăng ký");
        }

        String code = generateSecureRandomCode();
        sendVerificationEmail(email, code);

        Cache cache = cacheManager.getCache(CACHE_NAME);
        if (cache != null) {
            cache.put(email, code);
        }

        return code;
    }

    private String generateSecureRandomCode() {
        int randomNumber = secureRandom.nextInt(1000000);
        return String.format("%06d", randomNumber);
    }

    private void sendVerificationEmail(String toEmail, String code) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("🔐 Mã xác thực đăng ký - Quản lý lớp học");
            message.setText("Xin chào!\n\n" +
                    "Mã xác thực của bạn là: " + code +
                    "\n\nMã có hiệu lực trong " + CODE_EXPIRATION_MINUTES + " phút." +
                    "\n\n⚠️ Lưu ý: Không chia sẻ mã này với bất kỳ ai." +
                    "\n\nNếu bạn không yêu cầu mã này, vui lòng bỏ qua email này." +
                    "\n\nTrân trọng,\nỨng dụng Quản lý lớp học");

            mailSender.send(message);
        } catch (Exception e) {
            throw new RuntimeException("Lỗi gửi email: " + e.getMessage());
        }
    }

    public boolean verifyCode(String email, String code) {
        Cache cache = cacheManager.getCache(CACHE_NAME);
        if (cache == null) {
            return false;
        }

        // Kiểm tra xem cache có tồn tại cho email không
        Cache.ValueWrapper wrapper = cache.get(email);
        if (wrapper == null) {
            return false;
        }

        String storedCode = (String) wrapper.get();

        return code != null && code.equals(storedCode);
    }

    public void markEmailAsVerified(String email) {
        Cache cache = cacheManager.getCache(VERIFIED_EMAILS_CACHE);
        if (cache != null) {
            cache.put(email, true);
        }
    }

    public void clearVerificationOTPStatus(String email) {
        // Xóa mã OTP và trạng thái xác thực
        Cache cache = cacheManager.getCache(CACHE_NAME);
        if (cache != null) {
            cache.evict(email);
        }

        Cache verifiedCache = cacheManager.getCache(VERIFIED_EMAILS_CACHE);
        if (verifiedCache != null) {
            verifiedCache.evict(email);
        }
    }

    @Scheduled(fixedRate = 300000) // Dọn dẹp mỗi 5 phút
    public void cleanupExpiredCodes() {
        // Cache sẽ tự động hết hạn theo cấu hình
    }
}