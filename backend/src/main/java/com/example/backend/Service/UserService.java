package com.example.backend.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.backend.Model.User;
import com.example.backend.Repository.UserRepository;

@Service
public class UserService {
    
    @Autowired 
    private UserRepository userRepository;
    
    @Autowired 
    private PasswordEncoder passwordEncoder;

    public boolean login(String email, String password) {
        Optional<User> optionalUser = userRepository.findByEmail(email);

        if(optionalUser.isPresent()){
            User user = optionalUser.get();
            return passwordEncoder.matches(password, user.getPassword());
        }
        return false;
    }

    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
        .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy người dùng"));
    }

    @Transactional
    public boolean register(String fullName, String email, String password, User.Role role) {
        try {
            // Kiểm tra email đã tồn tại
            if (userRepository.existsByEmail(email)) {
                return false;
            }

            String encodedPassword = passwordEncoder.encode(password);
            User newUser = new User(email, encodedPassword, fullName, role);
            userRepository.save(newUser);

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    @Transactional
    public boolean registerStudent(String fullName, String email, String password) {
        return register(fullName, email, password, User.Role.STUDENT);
    }

    @Transactional
    public boolean registerTeacher(String fullName, String email, String password) {
        return register(fullName, email, password, User.Role.TEACHER);
    }

    @Transactional(readOnly = true)
    public boolean checkEmailExists(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional(readOnly = true)
    public List<User> searchStudents(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            // Trả về tất cả sinh viên nếu không có keyword
            return userRepository.findAll().stream()
                    .filter(user -> user.getRole() == User.Role.STUDENT)
                    .collect(Collectors.toList());
        }
        return userRepository.searchStudents(keyword.trim());
    }
}
